import 'package:flutter/material.dart';
import 'app_feedback.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'entertainment.dart';
import 'quotes_page.dart';
import 'extra_tools.dart';
import 'language_learning.dart';

const gold = Color(0xFFC9A227);
const green = Color(0xFF073B2B);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // AdMob is intentionally not initialized until real app/ad-unit IDs are added.
  runApp(const AlQoudApp());
}

class AlQoudApp extends StatelessWidget {
  const AlQoudApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'ALQOUD TOOLS',
    theme: ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: const Color(0xFF071B16),
      colorScheme: ColorScheme.fromSeed(seedColor: gold, brightness: Brightness.dark),
      useMaterial3: true,
      appBarTheme: const AppBarTheme(backgroundColor: green, foregroundColor: gold),
      inputDecorationTheme: const InputDecorationTheme(
        border: OutlineInputBorder(),
        focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: gold)),
      ),
    ),
    home: const SplashScreen(),
  );
}


class AlQoudLogo extends StatelessWidget {
  final double size;
  const AlQoudLogo({super.key, this.size = 64});
  @override
  Widget build(BuildContext context) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      gradient: const LinearGradient(
        colors: [Color(0xFFE8D9A0), Color(0xFFC9A227), Color(0xFF805D16)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      boxShadow: [BoxShadow(color: gold.withOpacity(.22), blurRadius: 18, spreadRadius: 2)],
    ),
    padding: const EdgeInsets.all(3),
    child: Container(
      decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xFF073B2B)),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Icon(Icons.shield_moon_outlined, color: gold, size: size * .68),
          Text('Q', style: TextStyle(color: const Color(0xFFE8D9A0), fontSize: size * .29, fontWeight: FontWeight.w900)),
        ],
      ),
    ),
  );
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}
class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _startWelcome();
    Future.delayed(const Duration(milliseconds: 4500), () {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => const HomePage(),
          transitionDuration: const Duration(milliseconds: 450),
          transitionsBuilder: (_, animation, __, child) => FadeTransition(opacity: animation, child: child),
        ),
      );
    });
  }

  Future<void> _startWelcome() async {
    await AppFeedback.speakWelcome();
    await AppFeedback.play(SoundCue.open);
  }

  @override
  Widget build(BuildContext context) => Directionality(
    textDirection: TextDirection.rtl,
    child: Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF14543D), Color(0xFF071B16), Color(0xFF04110D)],
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const AlQoudLogo(size: 116),
            const SizedBox(height: 24),
            const Text('ALQOUD TOOLS', style: TextStyle(color: Color(0xFFE8D9A0), fontSize: 27, fontWeight: FontWeight.w900, letterSpacing: 2.2)),
            const SizedBox(height: 9),
            const Text('الأدوات • المعرفة • التحدي', style: TextStyle(color: Colors.white70, fontSize: 15)),
            const SizedBox(height: 34),
            SizedBox(width: 90, child: LinearProgressIndicator(
              minHeight: 3,
              color: gold,
              backgroundColor: Colors.white12,
              borderRadius: BorderRadius.circular(8),
            )),
            const SizedBox(height: 16),
            const Text('اصنع إنجازك كل يوم', style: TextStyle(color: Colors.white54, fontSize: 12)),
          ],
        ),
      ),
    ),
  );
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}
class _HomePageState extends State<HomePage> {
  int tab = 0;
  int points = 0;
  final List<int> _tabHistory = [];

  void _selectTab(int next) {
    if (next == tab) return;
    setState(() {
      _tabHistory.remove(next);
      _tabHistory.add(tab);
      tab = next;
    });
  }

  void _handleSystemBack() {
    if (!mounted) return;
    if (_tabHistory.isNotEmpty) {
      setState(() => tab = _tabHistory.removeLast());
    } else if (tab != 0) {
      setState(() => tab = 0);
    } else {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(const SnackBar(
          content: Text('أنت في الصفحة الرئيسية. استخدم زر الرجوع للتنقل بين الأقسام.'),
          duration: Duration(seconds: 2),
        ));
    }
  }

  @override
  void initState() { super.initState(); _loadPoints(); }
  Future<void> _loadPoints() async {
    final p = await SharedPreferences.getInstance();
    if (mounted) setState(() => points = p.getInt('game_points') ?? 0);
  }
  Future<void> addPoints(int n) async {
    final p = await SharedPreferences.getInstance();
    points += n;
    await p.setInt('game_points', points);
    if (mounted) setState(() {});
  }
  @override
  Widget build(BuildContext context) {
    final pages = [
      _Dashboard(points: points, go: _selectTab),
      GamesHubPage(onEarn: addPoints),
      ChallengesPage(onEarn: addPoints),
      const QuoteLibraryPage(),
      const ToolsPage(),
      const LanguageLearningPage(),
    ];
    return Directionality(
      textDirection: TextDirection.rtl,
      child: PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) {
          if (!didPop) _handleSystemBack();
        },
        child: Scaffold(
          body: SafeArea(child: IndexedStack(index: tab, children: pages)),
          bottomNavigationBar: NavigationBar(
            backgroundColor: [green, const Color(0xFF15566A), const Color(0xFF813C4A), const Color(0xFF49316E), const Color(0xFF183B63), const Color(0xFF29244D)][tab],
            indicatorColor: Colors.white.withOpacity(.18),
            selectedIndex: tab,
            onDestinationSelected: _selectTab,
            destinations: const [
              NavigationDestination(icon: Icon(Icons.home_outlined), label: 'الرئيسية'),
              NavigationDestination(icon: Icon(Icons.sports_esports_outlined), label: 'ألعاب'),
              NavigationDestination(icon: Icon(Icons.today_outlined), label: 'اليومي'),
              NavigationDestination(icon: Icon(Icons.format_quote), label: 'عبارات'),
              NavigationDestination(icon: Icon(Icons.calculate_outlined), label: 'الأدوات'),
              NavigationDestination(icon: Icon(Icons.language_rounded), label: 'اللغات'),
            ],
          ),
        ),
      ),
    );
  }
}
class _Dashboard extends StatelessWidget {
  final int points;
  final ValueChanged<int> go;
  const _Dashboard({required this.points, required this.go});

  @override
  Widget build(BuildContext context) {
    final level = points >= 700 ? 4 : points >= 300 ? 3 : points >= 100 ? 2 : 1;
    final levelName = ['مستكشف', 'متعلّم', 'مبدع', 'عبقري', 'أسطورة'][level];
    final lower = level == 1 ? 0 : level == 2 ? 100 : level == 3 ? 300 : 700;
    final upper = level == 1 ? 100 : level == 2 ? 300 : level == 3 ? 700 : 1000;
    final progress = level == 4 ? 1.0 : ((points - lower) / (upper - lower)).clamp(0.0, 1.0);

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF071B16), Color(0xFF0A2B20), Color(0xFF061710)],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
      ),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(18, 14, 18, 28),
        children: [
          Row(
            children: [
              const AlQoudLogo(size: 48),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('ALQOUD TOOLS', style: TextStyle(color: Color(0xFFE8D9A0), fontSize: 17, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
                    SizedBox(height: 3),
                    Text('مساحتك للمعرفة والمرح', style: TextStyle(color: Colors.white60, fontSize: 12)),
                  ],
                ),
              ),
              Container(
                decoration: BoxDecoration(color: Colors.white.withOpacity(.07), shape: BoxShape.circle, border: Border.all(color: Colors.white12)),
                child: IconButton(
                  tooltip: 'الأدوات والإعدادات',
                  onPressed: () => go(4),
                  icon: const Icon(Icons.tune_rounded, color: Color(0xFFE8D9A0)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),
          Container(
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
              gradient: const LinearGradient(
                colors: [Color(0xFF1C6A4B), Color(0xFF10422F), Color(0xFF09251B)],
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
              ),
              border: Border.all(color: gold.withOpacity(.75), width: 1.1),
              boxShadow: [BoxShadow(color: const Color(0xFF0B9B65).withOpacity(.13), blurRadius: 26, offset: const Offset(0, 12))],
            ),
            child: Stack(
              children: [
                Positioned(left: -38, top: -48, child: Container(width: 160, height: 160, decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.white.withOpacity(.08), width: 22)))),
                Positioned(left: 48, bottom: -75, child: Container(width: 130, height: 130, decoration: BoxDecoration(shape: BoxShape.circle, color: gold.withOpacity(.06)))),
                Padding(
                  padding: const EdgeInsets.all(21),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
                        decoration: BoxDecoration(color: Colors.black.withOpacity(.16), borderRadius: BorderRadius.circular(30), border: Border.all(color: Colors.white12)),
                        child: const Row(mainAxisSize: MainAxisSize.min, children: [
                          Icon(Icons.auto_awesome, size: 14, color: Color(0xFFE8D9A0)),
                          SizedBox(width: 6),
                          Text('رحلتك تبدأ من هنا', style: TextStyle(color: Color(0xFFE8D9A0), fontSize: 11, fontWeight: FontWeight.bold)),
                        ]),
                      ),
                      const SizedBox(height: 15),
                      const Text('مرحباً بك! 👋', style: TextStyle(fontSize: 25, fontWeight: FontWeight.w900)),
                      const SizedBox(height: 5),
                      const Text('اكتشف، فكّر، العب، وتعلّم شيئاً جديداً كل يوم.', style: TextStyle(color: Colors.white70, height: 1.5, fontSize: 13)),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: _StatTile(icon: Icons.stars_rounded, label: 'رصيدك', value: '$points نقطة'),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _StatTile(icon: Icons.workspace_premium_rounded, label: 'مستواك', value: levelName),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          const Expanded(child: Text('تقدمك للمستوى التالي', style: TextStyle(color: Colors.white70, fontSize: 11))),
                          Text(level == 4 ? 'وصلت للقمة!' : '${(progress * 100).round()}%', style: const TextStyle(color: Color(0xFFE8D9A0), fontWeight: FontWeight.bold, fontSize: 11)),
                        ],
                      ),
                      const SizedBox(height: 7),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: LinearProgressIndicator(value: progress, minHeight: 8, color: const Color(0xFFE8D9A0), backgroundColor: Colors.black.withOpacity(.2)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 25),
          Row(
            children: [
              const Expanded(child: Text('ماذا تريد أن تفعل؟', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900))),
              Text('اختر واستمتع', style: TextStyle(color: Colors.white.withOpacity(.48), fontSize: 11)),
            ],
          ),
          const SizedBox(height: 12),
          GridView.count(
            crossAxisCount: 2,
            crossAxisSpacing: 11,
            mainAxisSpacing: 11,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: .96,
            children: [
              _FeatureCard(title: 'الألعاب والاختبارات', subtitle: 'ألغاز وأسئلة وذكاء', icon: Icons.extension_rounded, colors: const [Color(0xFF17664B), Color(0xFF103B2C)], onTap: () => go(1)),
              _FeatureCard(title: 'تحدي اليوم', subtitle: 'مهمة جديدة كل يوم', icon: Icons.bolt_rounded, colors: const [Color(0xFF76551D), Color(0xFF3F3219)], onTap: () => go(2)),
              _FeatureCard(title: 'عبارات ملهمة', subtitle: 'كلمات تحفظها وتشاركها', icon: Icons.format_quote_rounded, colors: const [Color(0xFF354D83), Color(0xFF202E50)], onTap: () => go(3)),
              _FeatureCard(title: 'الأدوات الذكية', subtitle: 'حاسبات وأدوات مفيدة', icon: Icons.auto_awesome_rounded, colors: const [Color(0xFF69406F), Color(0xFF3E294B)], onTap: () => go(4)),
              _FeatureCard(title: 'تعلم اللغات', subtitle: 'كلمات وحروف ونطق وقصص', icon: Icons.language_rounded, colors: const [Color(0xFF654A9D), Color(0xFF28254F)], onTap: () => go(5)),
            ],
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(.045),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withOpacity(.08)),
            ),
            child: const Row(
              children: [
                Icon(Icons.lightbulb_outline_rounded, color: Color(0xFFE8D9A0), size: 27),
                SizedBox(width: 12),
                Expanded(child: Text('كل يوم فرصة لتتعلم شيئاً جديداً. استمتع برحلتك ولا تتوقف عن الاكتشاف!', style: TextStyle(color: Colors.white70, height: 1.55, fontSize: 12))),
              ],
            ),
          ),
          const SizedBox(height: 13),
          const Center(child: Text('صُمّم ليكون وقتك أجمل ✦ ALQOUD TOOLS', style: TextStyle(color: Colors.white30, fontSize: 10))),
        ],
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _StatTile({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
    decoration: BoxDecoration(color: Colors.black.withOpacity(.16), borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white.withOpacity(.09))),
    child: Row(children: [
      Icon(icon, color: const Color(0xFFE8D9A0), size: 22),
      const SizedBox(width: 8),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: const TextStyle(color: Colors.white60, fontSize: 10)),
        const SizedBox(height: 3),
        Text(value, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
      ])),
    ]),
  );
}

class _FeatureCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final List<Color> colors;
  final VoidCallback onTap;
  const _FeatureCard({required this.title, required this.subtitle, required this.icon, required this.colors, required this.onTap});

  @override
  Widget build(BuildContext context) => Material(
    color: Colors.transparent,
    child: InkWell(
      borderRadius: BorderRadius.circular(21),
      onTap: onTap,
      child: Ink(
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: colors, begin: Alignment.topRight, end: Alignment.bottomLeft),
          borderRadius: BorderRadius.circular(21),
          border: Border.all(color: Colors.white.withOpacity(.10)),
          boxShadow: [BoxShadow(color: colors.first.withOpacity(.16), blurRadius: 14, offset: const Offset(0, 6))],
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 43,
                height: 43,
                decoration: BoxDecoration(color: Colors.white.withOpacity(.12), borderRadius: BorderRadius.circular(14)),
                child: Icon(icon, color: const Color(0xFFFFE8A2), size: 25),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14)),
                  const SizedBox(height: 4),
                  Text(subtitle, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white70, fontSize: 10)),
                ],
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

class ToolsPage extends StatefulWidget {
  const ToolsPage({super.key});
  @override
  State<ToolsPage> createState() => _ToolsPageState();
}
class _ToolsPageState extends State<ToolsPage> {
  bool reminderEnabled = false;
  bool soundEnabled = true;

  Future<void> _enableReminder() async {
    try {
      final ok = await ReminderService.scheduleDaily();
      if (!mounted) return;
      setState(() => reminderEnabled = ok);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(ok
            ? 'تم تفعيل التذكير اليومي الساعة 7 مساءً.'
            : 'لم يتم منح إذن الإشعارات. فعّله من إعدادات الهاتف.'),
      ));
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تعذر تفعيل التذكير على هذا الجهاز.')),
      );
    }
  }

  Future<void> _disableReminder() async {
    await ReminderService.cancelDaily();
    if (mounted) setState(() => reminderEnabled = false);
  }

  @override
  void initState() {
    super.initState();
    _loadSoundSetting();
  }

  Future<void> _loadSoundSetting() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) setState(() => soundEnabled = prefs.getBool('sound_enabled') ?? true);
  }

  Future<void> _changeSound(bool value) async {
    await AppFeedback.setEnabled(value);
    if (mounted) setState(() => soundEnabled = value);
  }

  @override
  Widget build(BuildContext context) {
    final tools = <(String, IconData, Widget)>[
      ('حاسبة الأرباح', Icons.trending_up, const ProfitPage()),
      ('حاسبة الخصومات', Icons.percent, const DiscountPage()),
      ('حاسبة الأقساط', Icons.calendar_month, const InstallmentPage()),
      ('الجملة والتجزئة', Icons.storefront, const WholesalePage()),
      ('الفواتير المحفوظة', Icons.receipt_long, const SavedPage()),
      ('دفتر المصروفات والإيرادات', Icons.account_balance_wallet_rounded, const ExpenseBookPage()),
      ('محول الوحدات', Icons.swap_horiz_rounded, const UnitConverterPage()),
      ('ملاحظاتي السريعة', Icons.sticky_note_2_rounded, const QuickNotesPage()),
      ('إنجازاتي وشاراتي', Icons.workspace_premium_rounded, const AchievementsPage()),
    ];
    return Scaffold(
      backgroundColor: const Color(0xFF101D35),
      appBar: AppBar(backgroundColor: const Color(0xFF183B63), foregroundColor: const Color(0xFFD8E8FF), title: const Text('الأدوات والحاسبات')),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        Card(
          color: const Color(0xFF1A3455),
          child: SwitchListTile(
            secondary: const Icon(Icons.volume_up_rounded, color: gold),
            title: const Text('المؤثرات الصوتية'),
            subtitle: const Text('أصوات هادئة عند فتح التطبيق والإجابة والإنجاز'),
            value: soundEnabled,
            onChanged: _changeSound,
          ),
        ),
        Card(
          color: const Color(0xFF1A3455),
          child: ListTile(
            leading: const Icon(Icons.music_note_rounded, color: gold),
            title: const Text('تجربة الصوت'),
            subtitle: const Text('اضغط للتأكد من عمل المؤثرات الصوتية'),
            trailing: const Icon(Icons.play_circle_fill_rounded, color: gold),
            onTap: () async {
              await AppFeedback.testSound();
              if (!mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('تم تشغيل اختبار الصوت. تأكد من مستوى صوت الوسائط.')),
              );
            },
          ),
        ),
        Card(
          color: const Color(0xFF1A3455),
          child: SwitchListTile(
            secondary: const Icon(Icons.notifications_active, color: Color(0xFFD8E8FF)),
            title: const Text('التذكير اليومي'),
            subtitle: const Text('إشعار يومي الساعة 7 مساءً لتجربة تحدٍ جديد'),
            value: reminderEnabled,
            onChanged: (value) => value ? _enableReminder() : _disableReminder(),
          ),
        ),
        ...tools.map((t) => Card(child: ListTile(
        leading: Icon(t.$2, color: gold),
        title: Text(t.$1),
        trailing: const Icon(Icons.chevron_left),
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => t.$3)),
      ))),
      ]),
    );
  }
}

class CalcPage extends StatefulWidget {
  final String title;
  final List<String> labels;
  final String Function(List<double>) calculate;
  const CalcPage({super.key, required this.title, required this.labels, required this.calculate});
  @override
  State<CalcPage> createState() => _CalcPageState();
}
class _CalcPageState extends State<CalcPage> {
  late final List<TextEditingController> controllers =
      List.generate(widget.labels.length, (_) => TextEditingController());
  String result = 'أدخل البيانات ثم اضغط احسب';
  @override
  void dispose() { for (final c in controllers) { c.dispose(); } super.dispose(); }
  Color get _accent {
    if (widget.title.contains('الأرباح')) return const Color(0xFF58D6A5);
    if (widget.title.contains('الخصومات')) return const Color(0xFFFF83A8);
    if (widget.title.contains('الأقساط')) return const Color(0xFF70B8FF);
    return const Color(0xFFC19BFF);
  }
  Color get _pageBackground {
    if (widget.title.contains('الأرباح')) return const Color(0xFF102B25);
    if (widget.title.contains('الخصومات')) return const Color(0xFF321F2B);
    if (widget.title.contains('الأقساط')) return const Color(0xFF172B42);
    return const Color(0xFF2A2140);
  }
  @override
  Widget build(BuildContext context) => Directionality(
    textDirection: TextDirection.rtl,
    child: Scaffold(
      backgroundColor: _pageBackground,
      appBar: AppBar(backgroundColor: _accent.withOpacity(.18), foregroundColor: _accent, title: Text(widget.title)),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        ...List.generate(widget.labels.length, (i) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: TextField(
            controller: controllers[i],
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(labelText: widget.labels[i]),
          ),
        )),
        FilledButton(
          style: FilledButton.styleFrom(backgroundColor: _accent, foregroundColor: const Color(0xFF101522)),
          onPressed: () {
            final values = controllers.map((c) => double.tryParse(c.text.trim()) ?? double.nan).toList();
            if (values.any((v) => !v.isFinite)) { setState(() => result = 'يرجى إدخال أرقام صحيحة في جميع الخانات'); return; }
            setState(() => result = widget.calculate(values));
          },
          child: const Text('احسب'),
        ),
        const SizedBox(height: 16),
        Card(color: _accent.withOpacity(.16), child: Padding(padding: const EdgeInsets.all(18), child: SelectableText(result, style: TextStyle(fontSize: 18, color: _accent, fontWeight: FontWeight.w700)))),
      ]),
    ),
  );
}

class ProfitPage extends StatelessWidget {
  const ProfitPage({super.key});
  @override
  Widget build(BuildContext context) => CalcPage(
    title: 'حاسبة الأرباح',
    labels: const ['سعر الشراء', 'سعر البيع', 'المصاريف الإضافية'],
    calculate: (v) {
      if (v[0] <= 0 || v[1] < 0 || v[2] < 0) return 'تحقق من القيم المدخلة';
      final p = v[1] - v[0] - v[2];
      return 'صافي الربح: ${p.toStringAsFixed(2)}\nنسبة الربح على التكلفة: ${(p / v[0] * 100).toStringAsFixed(2)}%';
    },
  );
}
class DiscountPage extends StatelessWidget {
  const DiscountPage({super.key});
  @override
  Widget build(BuildContext context) => CalcPage(
    title: 'حاسبة الخصومات', labels: const ['السعر الأصلي', 'نسبة الخصم %'],
    calculate: (v) {
      if (v[0] <= 0 || v[1] < 0 || v[1] > 100) return 'تحقق من السعر ونسبة الخصم';
      final d = v[0] * v[1] / 100;
      return 'قيمة الخصم: ${d.toStringAsFixed(2)}\nالسعر بعد الخصم: ${(v[0]-d).toStringAsFixed(2)}';
    },
  );
}
class InstallmentPage extends StatelessWidget {
  const InstallmentPage({super.key});
  @override
  Widget build(BuildContext context) => CalcPage(
    title: 'حاسبة الأقساط', labels: const ['المبلغ الإجمالي', 'عدد الأشهر'],
    calculate: (v) {
      if (v[0] <= 0 || v[1] <= 0 || v[1] != v[1].roundToDouble()) return 'أدخل مبلغاً وعدداً صحيحاً من الأشهر';
      return 'القسط الشهري: ${(v[0]/v[1]).toStringAsFixed(2)}';
    },
  );
}
class WholesalePage extends StatelessWidget {
  const WholesalePage({super.key});
  @override
  Widget build(BuildContext context) => CalcPage(
    title: 'الجملة والتجزئة', labels: const ['تكلفة القطعة', 'نسبة الربح %', 'عدد القطع'],
    calculate: (v) {
      if (v[0] <= 0 || v[1] < 0 || v[2] <= 0) return 'تحقق من القيم المدخلة';
      final unit = v[0] * (1 + v[1]/100);
      return 'سعر بيع القطعة: ${unit.toStringAsFixed(2)}\nإجمالي البيع: ${(unit*v[2]).toStringAsFixed(2)}\nإجمالي الربح: ${((unit-v[0])*v[2]).toStringAsFixed(2)}';
    },
  );
}
class SavedPage extends StatefulWidget {
  const SavedPage({super.key});
  @override
  State<SavedPage> createState() => _SavedPageState();
}
class _SavedPageState extends State<SavedPage> {
  final name = TextEditingController();
  final amount = TextEditingController();
  List<String> items = [];
  @override
  void initState() { super.initState(); load(); }
  Future<void> load() async {
    final p = await SharedPreferences.getInstance();
    setState(() => items = p.getStringList('invoices') ?? []);
  }
  Future<void> add() async {
    final n = name.text.trim();
    final a = double.tryParse(amount.text.trim());
    if (n.isEmpty || a == null || a < 0) return;
    final p = await SharedPreferences.getInstance();
    items = [...items, '$n — ${a.toStringAsFixed(2)}'];
    await p.setStringList('invoices', items);
    name.clear(); amount.clear(); setState(() {});
  }
  @override
  void dispose() { name.dispose(); amount.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) => Directionality(
    textDirection: TextDirection.rtl,
    child: Scaffold(
      backgroundColor: const Color(0xFF20172F),
      appBar: AppBar(backgroundColor: const Color(0xFF49316A), foregroundColor: const Color(0xFFE6D5FF), title: const Text('الفواتير المحفوظة')),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        TextField(controller: name, decoration: const InputDecoration(labelText: 'اسم العميل أو الفاتورة')),
        const SizedBox(height: 10),
        TextField(controller: amount, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'المبلغ')),
        const SizedBox(height: 10),
        FilledButton(style: FilledButton.styleFrom(backgroundColor: const Color(0xFFB99AEF), foregroundColor: const Color(0xFF241832)), onPressed: add, child: const Text('حفظ محلياً')),
        const SizedBox(height: 16),
        ...items.asMap().entries.map((e) => Card(child: ListTile(title: Text(e.value), trailing: IconButton(
          icon: const Icon(Icons.delete_outline),
          onPressed: () async {
            final p = await SharedPreferences.getInstance();
            items.removeAt(e.key); await p.setStringList('invoices', items); setState(() {});
          },
        )))),
        if (items.isEmpty) const Text('لا توجد فواتير محفوظة بعد.'),
      ]),
    ),
  );
}
