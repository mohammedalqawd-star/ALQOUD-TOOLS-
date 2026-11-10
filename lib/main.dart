import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'entertainment.dart';

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
    home: const HomePage(),
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
      _Dashboard(points: points, go: (i) => setState(() => tab = i)),
      QuizPage(onEarn: addPoints),
      ChallengesPage(onEarn: addPoints),
      const QuotesPage(),
      const ToolsPage(),
    ];
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: SafeArea(child: IndexedStack(index: tab, children: pages)),
        bottomNavigationBar: NavigationBar(
          backgroundColor: green,
          indicatorColor: gold.withOpacity(.2),
          selectedIndex: tab,
          onDestinationSelected: (i) => setState(() => tab = i),
          destinations: const [
            NavigationDestination(icon: Icon(Icons.home_outlined), label: 'الرئيسية'),
            NavigationDestination(icon: Icon(Icons.quiz_outlined), label: 'اختبارات'),
            NavigationDestination(icon: Icon(Icons.celebration_outlined), label: 'تحديات'),
            NavigationDestination(icon: Icon(Icons.format_quote), label: 'عبارات'),
            NavigationDestination(icon: Icon(Icons.calculate_outlined), label: 'الأدوات'),
          ],
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
  Widget build(BuildContext context) => ListView(padding: const EdgeInsets.all(16), children: [
    Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFF14543D), Color(0xFF071B16)]),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: gold),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('ALQOUD', style: TextStyle(color: gold, letterSpacing: 3, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        const Text('تعلّم، تحدَّ نفسك، واستمتع!', style: TextStyle(fontSize: 23, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        const Text('اختبارات وأسئلة وتحديات وعبارات جميلة في مكان واحد.'),
        const SizedBox(height: 16),
        Text('★  ' + points.toString() + ' نقطة', style: const TextStyle(color: gold, fontSize: 20, fontWeight: FontWeight.bold)),
      ]),
    ),
    const SizedBox(height: 18),
    const Text('الأقسام الرئيسية', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
    const SizedBox(height: 8),
    _menuCard('اختبارات وأسئلة', 'اختبر معلوماتك واجمع النقاط', Icons.quiz, () => go(1)),
    _menuCard('تحديات مضحكة', 'مهام خفيفة ومواقف مرحة', Icons.celebration, () => go(2)),
    _menuCard('عبارات جميلة', 'كلمات تحفيزية وحكم قصيرة', Icons.format_quote, () => go(3)),
    _menuCard('الأدوات والحاسبات', 'الأرباح والخصومات والفواتير', Icons.calculate, () => go(4)),
    const SizedBox(height: 8),
    const Text('النقاط للمتعة والتنافس الودي فقط، ولا توجد مراهنات أو جوائز مالية.', style: TextStyle(color: Colors.white60, fontSize: 12)),
  ]);
}
Widget _menuCard(String title, String subtitle, IconData icon, VoidCallback action) => Card(
  child: ListTile(
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
    leading: CircleAvatar(backgroundColor: gold.withOpacity(.15), child: Icon(icon, color: gold)),
    title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
    subtitle: Text(subtitle),
    trailing: const Icon(Icons.arrow_back_ios_new, color: gold, size: 16),
    onTap: action,
  ),
);
class ToolsPage extends StatelessWidget {
  const ToolsPage({super.key});
  @override
  Widget build(BuildContext context) {
    final tools = <(String, IconData, Widget)>[
      ('حاسبة الأرباح', Icons.trending_up, const ProfitPage()),
      ('حاسبة الخصومات', Icons.percent, const DiscountPage()),
      ('حاسبة الأقساط', Icons.calendar_month, const InstallmentPage()),
      ('الجملة والتجزئة', Icons.storefront, const WholesalePage()),
      ('الفواتير المحفوظة', Icons.receipt_long, const SavedPage()),
    ];
    return Scaffold(
      appBar: AppBar(title: const Text('الأدوات والحاسبات')),
      body: ListView(padding: const EdgeInsets.all(16), children: tools.map((t) => Card(child: ListTile(
        leading: Icon(t.$2, color: gold),
        title: Text(t.$1),
        trailing: const Icon(Icons.chevron_left),
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => t.$3)),
      ))).toList()),
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
  @override
  Widget build(BuildContext context) => Directionality(
    textDirection: TextDirection.rtl,
    child: Scaffold(
      appBar: AppBar(title: Text(widget.title)),
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
          style: FilledButton.styleFrom(backgroundColor: gold, foregroundColor: Colors.black),
          onPressed: () {
            final values = controllers.map((c) => double.tryParse(c.text.trim()) ?? double.nan).toList();
            if (values.any((v) => !v.isFinite)) { setState(() => result = 'يرجى إدخال أرقام صحيحة في جميع الخانات'); return; }
            setState(() => result = widget.calculate(values));
          },
          child: const Text('احسب'),
        ),
        const SizedBox(height: 16),
        Card(color: green, child: Padding(padding: const EdgeInsets.all(18), child: SelectableText(result, style: const TextStyle(fontSize: 18, color: Color(0xFFE8D9A0))))),
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
      appBar: AppBar(title: const Text('الفواتير المحفوظة')),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        TextField(controller: name, decoration: const InputDecoration(labelText: 'اسم العميل أو الفاتورة')),
        const SizedBox(height: 10),
        TextField(controller: amount, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'المبلغ')),
        const SizedBox(height: 10),
        FilledButton(onPressed: add, child: const Text('حفظ محلياً')),
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
