import 'dart:async';
import 'dart:math' as math;
import 'app_feedback.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

const gold = Color(0xFFE0B84F);
const green = Color(0xFF0B3D2E);
const deep = Color(0xFF071B16);
const panel = Color(0xFF102B22);

Future<bool> awardOnce(String id, int points, Future<void> Function(int) earn) async {
  final p = await SharedPreferences.getInstance();
  final done = p.getStringList('earned_events') ?? <String>[];
  if (done.contains(id)) return false;
  done.add(id);
  await p.setStringList('earned_events', done);
  await earn(points);
  return true;
}

Future<List<int>> loadUnseenOrder(String key, int length) async {
  final prefs = await SharedPreferences.getInstance();
  final seen = (prefs.getStringList(key) ?? <String>[]).toSet();
  var available = List<int>.generate(length, (i) => i)
      .where((i) => !seen.contains(i.toString())).toList();
  if (available.isEmpty) {
    await prefs.remove(key);
    available = List<int>.generate(length, (i) => i);
  }
  available.shuffle(math.Random());
  return available;
}

Future<void> markItemSeen(String key, int index) async {
  final prefs = await SharedPreferences.getInstance();
  final seen = prefs.getStringList(key) ?? <String>[];
  final value = index.toString();
  if (!seen.contains(value)) {
    seen.add(value);
    await prefs.setStringList(key, seen);
  }
}
String cleanAnswer(String s) => s.trim().toLowerCase()
  .replaceAll(RegExp(r'[\u064B-\u065F\u0670]'), '')
  .replaceAll('أ', 'ا').replaceAll('إ', 'ا').replaceAll('آ', 'ا')
  .replaceAll('ى', 'ي').replaceAll(RegExp(r'\s+'), '');

class GamesHubPage extends StatelessWidget {
  final Future<void> Function(int) onEarn;
  const GamesHubPage({super.key, required this.onEarn});

  @override
  Widget build(BuildContext context) {
    final cards = <_SquareGameCard>[
      _SquareGameCard(title: 'اختبارات المعلومات', subtitle: 'ثلاثة مستويات', icon: Icons.quiz_rounded, color: const Color(0xFF38B887), tag: 'معرفة', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => QuizLevelsPage(onEarn: onEarn)))),
      _SquareGameCard(title: 'ألغاز وذكاء', subtitle: 'فكّر واكتشف الحل', icon: Icons.psychology_alt_rounded, color: const Color(0xFF9B83E8), tag: 'تفكير', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => RiddlesPage(onEarn: onEarn)))),
      _SquareGameCard(title: 'خمن الكلمة', subtitle: 'اكتشفها من التلميح', icon: Icons.lightbulb_rounded, color: const Color(0xFFD49A39), tag: 'تخمين', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => GuessWordPage(onEarn: onEarn)))),
      _SquareGameCard(title: 'لعبة الذاكرة', subtitle: 'طابق البطاقات', icon: Icons.grid_view_rounded, color: const Color(0xFF56C7D8), tag: 'ذاكرة', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => MemoryPairsPage(onEarn: onEarn)))),
      _SquareGameCard(title: 'صح أم خطأ', subtitle: 'قرّر بسرعة', icon: Icons.fact_check_rounded, color: const Color(0xFFFF8A80), tag: 'سرعة', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => TrueFalsePage(onEarn: onEarn)))),
      _SquareGameCard(title: 'معاني الكلمات', subtitle: 'وسّع مفرداتك', icon: Icons.menu_book_rounded, color: const Color(0xFF83B7FF), tag: 'لغة', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => MeaningWordPage(onEarn: onEarn)))),
      _SquareGameCard(title: 'التحدي المفتوح', subtitle: 'أسئلة بلا نهاية', icon: Icons.all_inclusive_rounded, color: const Color(0xFF4DD0A1), tag: 'مستمر', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => EndlessQuizPage(onEarn: onEarn)))),
      _SquareGameCard(title: 'تحدي اليوم', subtitle: '10 أسئلة متجددة', icon: Icons.today_rounded, color: const Color(0xFFFFC15A), tag: 'يومي', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => QuizPlayPage(title: 'تحدي اليوم', questions: generatedQuestionBank(), levelKey: 'daily_1200_pool', questionLimit: 10, onEarn: onEarn)))),
      _SquareGameCard(title: 'تحدي 60 ثانية', subtitle: 'كم إجابة تجمع؟', icon: Icons.timer_rounded, color: const Color(0xFFFF8A65), tag: 'سرعة', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => SpeedChallengePage(onEarn: onEarn)))),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFF102B36),
      appBar: AppBar(backgroundColor: const Color(0xFF15566A), foregroundColor: const Color(0xFF8CE6E0), title: const Text('الألعاب والتحديات')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
        children: [
          Container(
            padding: const EdgeInsets.all(21),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(26),
              gradient: const LinearGradient(colors: [Color(0xFF176247), Color(0xFF071B16)], begin: Alignment.topRight, end: Alignment.bottomLeft),
              border: Border.all(color: gold.withOpacity(.65)),
              boxShadow: [BoxShadow(color: const Color(0xFF0B9B65).withOpacity(.16), blurRadius: 22, offset: const Offset(0, 9))],
            ),
            child: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [Icon(Icons.auto_awesome_rounded, color: gold, size: 18), SizedBox(width: 7), Text('ALQOUD • GAME ZONE', style: TextStyle(color: gold, letterSpacing: 1.2, fontWeight: FontWeight.w900, fontSize: 12))]),
              SizedBox(height: 12),
              Text('اختر لعبتك المفضلة', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900)),
              SizedBox(height: 6),
              Text('تسعة تحديات متنوعة؛ العب، اجمع النقاط، واكتشف مهارات جديدة.', style: TextStyle(color: Colors.white70, height: 1.5, fontSize: 12)),
            ]),
          ),
          const SizedBox(height: 22),
          Row(children: [
            const Expanded(child: Text('كل الألعاب', style: TextStyle(fontSize: 19, fontWeight: FontWeight.w900))),
            Text('٩ تصنيفات', style: TextStyle(color: Colors.white.withOpacity(.55), fontSize: 11)),
          ]),
          const SizedBox(height: 12),
          GridView.count(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: .94,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: cards,
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(13),
            decoration: BoxDecoration(color: Colors.white.withOpacity(.045), borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white10)),
            child: const Row(children: [
              Icon(Icons.info_outline_rounded, color: gold, size: 20),
              SizedBox(width: 9),
              Expanded(child: Text('النقاط رصيد إنجاز افتراضي داخل التطبيق فقط، وليست أموالاً ولا تُستخدم للمراهنة.', style: TextStyle(color: Colors.white60, fontSize: 11, height: 1.5))),
            ]),
          ),
        ],
      ),
    );
  }
}

class _SquareGameCard extends StatelessWidget {
  final String title, subtitle, tag;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const _SquareGameCard({required this.title, required this.subtitle, required this.icon, required this.color, required this.tag, required this.onTap});

  @override
  Widget build(BuildContext context) => Material(
    color: Colors.transparent,
    child: InkWell(
      borderRadius: BorderRadius.circular(23),
      onTap: onTap,
      child: Ink(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(23),
          gradient: LinearGradient(
            colors: [color.withOpacity(.27), const Color(0xFF12242D), const Color(0xFF0D1D26)],
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
          ),
          border: Border.all(color: color.withOpacity(.42), width: 1.1),
          boxShadow: [BoxShadow(color: color.withOpacity(.10), blurRadius: 15, offset: const Offset(0, 7))],
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Container(
                  width: 49, height: 49,
                  decoration: BoxDecoration(color: color.withOpacity(.18), borderRadius: BorderRadius.circular(16), border: Border.all(color: color.withOpacity(.35))),
                  child: Icon(icon, color: color, size: 28),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: color.withOpacity(.13), borderRadius: BorderRadius.circular(20)),
                  child: Text(tag, style: TextStyle(color: color, fontSize: 9, fontWeight: FontWeight.w800)),
                ),
              ]),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(title, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, height: 1.3)),
                const SizedBox(height: 5),
                Text(subtitle, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white60, fontSize: 10)),
                const SizedBox(height: 9),
                Row(children: [Text('ابدأ اللعب', style: TextStyle(color: color, fontWeight: FontWeight.w800, fontSize: 10)), const SizedBox(width: 5), Icon(Icons.arrow_back_rounded, color: color, size: 15)]),
              ]),
            ],
          ),
        ),
      ),
    ),
  );
}

class Q {
  final String text;
  final List<String> choices;
  final int answer;
  const Q(this.text, this.choices, this.answer);
}
const easy = <Q>[
  Q('كم عدد أيام الأسبوع؟', ['5','6','7','8'], 2),
  Q('ما عاصمة اليمن؟', ['صنعاء','عدن','تعز','إب'], 0),
  Q('كم ضلعاً للمثلث؟', ['2','3','4','5'], 1),
  Q('أي حيوان يلقب بسفينة الصحراء؟', ['الحصان','الجمل','الغزال','الفيل'], 1),
  Q('كم يساوي 5 × 6؟', ['25','30','35','40'], 1),
  Q('كم دقيقة في الساعة؟', ['30','45','60','100'], 2),
  Q('ما العضو الذي نستخدمه للرؤية؟', ['الأذن','العين','الأنف','اليد'], 1),
  Q('أي من هذه فاكهة؟', ['الجزر','الخيار','التفاح','البطاطس'], 2),
  Q('ما لون الموز الناضج غالباً؟', ['أزرق','أصفر','بنفسجي','أسود'], 1),
  Q('كم عدد أشهر السنة؟', ['10','11','12','13'], 2),
];
const medium = <Q>[
  Q('ما الكوكب المعروف بالكوكب الأحمر؟', ['الزهرة','المريخ','زحل','عطارد'], 1),
  Q('ما أكبر محيط على الأرض؟', ['الأطلسي','الهندي','المتجمد','الهادئ'], 3),
  Q('ما الغاز الذي تمتصه النباتات؟', ['الأكسجين','ثاني أكسيد الكربون','الهيليوم','الهيدروجين'], 1),
  Q('كم ضلعاً للشكل السداسي؟', ['5','6','7','8'], 1),
  Q('ما عاصمة اليابان؟', ['بكين','سيول','طوكيو','بانكوك'], 2),
  Q('ما ناتج 144 ÷ 12؟', ['10','11','12','14'], 2),
  Q('ما اسم صغير الحصان؟', ['جحش','مهر','حمل','عجل'], 1),
  Q('أي معدن رمزه الكيميائي Fe؟', ['الذهب','الحديد','الفضة','النحاس'], 1),
  Q('كم عدد قارات العالم في التصنيف الشائع؟', ['5','6','7','8'], 2),
  Q('ما عاصمة مصر؟', ['الإسكندرية','القاهرة','الأقصر','أسوان'], 1),
];
const hard = <Q>[
  Q('ما العنصر الكيميائي الذي رمزه W؟', ['الفضة','التنغستن','القصدير','الزنك'], 1),
  Q('ما أصغر عدد أولي؟', ['0','1','2','3'], 2),
  Q('ما عملية صنع النبات لغذائه؟', ['التبخر','البناء الضوئي','التكاثف','التخمر'], 1),
  Q('كم مجموع زوايا المثلث؟', ['90°','180°','270°','360°'], 1),
  Q('ما عاصمة أستراليا؟', ['سيدني','ملبورن','كانبيرا','بيرث'], 2),
  Q('ما وحدة قياس المقاومة الكهربائية؟', ['الفولت','الأمبير','الأوم','الواط'], 2),
  Q('ما الجهاز الذي يقيس الضغط الجوي؟', ['الترمومتر','البارومتر','الأميتر','الفولتميتر'], 1),
  Q('أي جزء من الخلية يحتوي غالباً على المادة الوراثية؟', ['النواة','الغشاء','الجدار','الفجوة'], 0),
  Q('ما العدد التالي: 2، 6، 12، 20، 30؟', ['36','40','42','44'], 2),
  Q('ما اسم المجرة التي تنتمي إليها مجموعتنا الشمسية؟', ['المرأة المسلسلة','درب التبانة','مجرة العين','السومبريرو'], 1),
];

class QuizLevelsPage extends StatelessWidget {
  final Future<void> Function(int) onEarn;
  const QuizLevelsPage({super.key, required this.onEarn});

  @override
  Widget build(BuildContext context) {
    final cards = <_SquareGameCard>[
      _SquareGameCard(title: 'مراحل المعلومات', subtitle: '1000 مرحلة • 10 أسئلة لكل مرحلة', icon: Icons.school_rounded, color: const Color(0xFF48B887), tag: '1000 مرحلة', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => StageLevelsPage(title: 'اختبار المعلومات', stageKey: 'info_stages', questions: [...easy, ...medium, ...hard], accent: const Color(0xFF48B887), onEarn: onEarn)))),
      _SquareGameCard(title: 'مراحل الحساب والذكاء', subtitle: '1000 مرحلة • 10 أسئلة لكل مرحلة', icon: Icons.calculate_rounded, color: const Color(0xFF83B7FF), tag: '1000 مرحلة', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => StageLevelsPage(title: 'الحساب والذكاء', stageKey: 'math_stages', questions: generatedQuestionBank(), accent: const Color(0xFF83B7FF), onEarn: onEarn)))),
      _SquareGameCard(title: 'التحدي المفتوح', subtitle: 'أسئلة حسابية بلا نهاية', icon: Icons.all_inclusive_rounded, color: const Color(0xFF4DD0A1), tag: 'مستمر', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => EndlessQuizPage(onEarn: onEarn)))),
      _SquareGameCard(title: 'اختبار اليوم', subtitle: '10 أسئلة متجددة', icon: Icons.today_rounded, color: const Color(0xFFD7B8FF), tag: 'يومي', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => QuizPlayPage(title: 'اختبار اليوم', questions: generatedQuestionBank(), levelKey: 'daily_1200_pool', questionLimit: 10, onEarn: onEarn)))),
    ];
    return Scaffold(
      backgroundColor: const Color(0xFF171D38),
      appBar: AppBar(backgroundColor: const Color(0xFF344B83), foregroundColor: const Color(0xFFB5C7FF), title: const Text('مركز المراحل')),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(25),
            gradient: const LinearGradient(colors: [Color(0xFF355C9A), Color(0xFF241D49)], begin: Alignment.topRight, end: Alignment.bottomLeft),
            border: Border.all(color: const Color(0xFFB5C7FF).withOpacity(.5)),
            boxShadow: [BoxShadow(color: const Color(0xFF668CFF).withOpacity(.18), blurRadius: 22, offset: const Offset(0, 8))],
          ),
          child: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('رحلة الألف مرحلة', style: TextStyle(color: Color(0xFFE3EAFF), fontSize: 23, fontWeight: FontWeight.w900)),
            SizedBox(height: 8),
            Text('أكمل 10 أسئلة في المرحلة لتُغلق نهائياً ويُفتح لك المستوى التالي. تقدمك محفوظ على جهازك.', style: TextStyle(color: Colors.white70, height: 1.55, fontSize: 12)),
          ]),
        ),
        const SizedBox(height: 18),
        GridView.count(crossAxisCount: 2, crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: .94, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), children: cards),
      ]),
    );
  }
}

class StageLevelsPage extends StatefulWidget {
  final String title, stageKey;
  final List<Q> questions;
  final Color accent;
  final Future<void> Function(int) onEarn;
  const StageLevelsPage({super.key, required this.title, required this.stageKey, required this.questions, required this.accent, required this.onEarn});
  @override
  State<StageLevelsPage> createState() => _StageLevelsPageState();
}
class _StageLevelsPageState extends State<StageLevelsPage> {
  int completed = 0;
  bool ready = false;
  static const int totalStages = 1000;
  @override
  void initState() { super.initState(); _load(); }
  Future<void> _load() async {
    final p = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() { completed = (p.getInt('completed_${widget.stageKey}') ?? 0).clamp(0, totalStages).toInt(); ready = true; });
  }
  Future<void> _openStage(int stage) async {
    if (stage != completed + 1 || stage > totalStages) return;
    await Navigator.push(context, MaterialPageRoute(builder: (_) => QuizPlayPage(
      title: '${widget.title} • المرحلة $stage',
      questions: widget.questions,
      levelKey: widget.stageKey,
      stageNumber: stage,
      onEarn: widget.onEarn,
    )));
    await _load();
  }
  @override
  Widget build(BuildContext context) {
    final progress = completed / totalStages;
    return Scaffold(
      backgroundColor: const Color(0xFF111D30),
      appBar: AppBar(backgroundColor: widget.accent.withOpacity(.22), foregroundColor: widget.accent, title: Text(widget.title)),
      body: !ready ? const Center(child: CircularProgressIndicator()) : Column(children: [
        Padding(padding: const EdgeInsets.fromLTRB(16, 16, 16, 10), child: Container(
          padding: const EdgeInsets.all(17),
          decoration: BoxDecoration(gradient: LinearGradient(colors: [widget.accent.withOpacity(.28), const Color(0xFF17263B)]), borderRadius: BorderRadius.circular(21), border: Border.all(color: widget.accent.withOpacity(.5))),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [Expanded(child: Text('إنجازك: $completed / $totalStages', style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900))), Icon(Icons.military_tech_rounded, color: widget.accent, size: 27)]),
            const SizedBox(height: 10),
            ClipRRect(borderRadius: BorderRadius.circular(12), child: LinearProgressIndicator(value: progress, minHeight: 9, color: widget.accent, backgroundColor: Colors.white12)),
            const SizedBox(height: 8),
            Text(completed == totalStages ? 'أكملت جميع المراحل!' : 'المرحلة المتاحة الآن: ${completed + 1} • 10 أسئلة', style: TextStyle(color: widget.accent, fontSize: 11, fontWeight: FontWeight.bold)),
          ]),
        )),
        Expanded(child: GridView.builder(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 22),
          itemCount: totalStages,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 4, crossAxisSpacing: 9, mainAxisSpacing: 9, childAspectRatio: 1),
          itemBuilder: (context, i) {
            final stage = i + 1;
            final isDone = stage <= completed;
            final isOpen = stage == completed + 1;
            final color = isDone ? const Color(0xFF435064) : isOpen ? widget.accent : const Color(0xFF202B3D);
            return Material(
              color: color.withOpacity(isOpen ? .24 : .75),
              borderRadius: BorderRadius.circular(13),
              child: InkWell(
                borderRadius: BorderRadius.circular(13),
                onTap: isOpen ? () => _openStage(stage) : null,
                child: Container(
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(13), border: Border.all(color: isOpen ? widget.accent : Colors.white.withOpacity(.07), width: isOpen ? 1.5 : 1)),
                  child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Icon(isDone ? Icons.lock_rounded : isOpen ? Icons.play_circle_fill_rounded : Icons.lock_outline_rounded, color: isOpen ? widget.accent : Colors.white38, size: 19),
                    const SizedBox(height: 4),
                    Text('$stage', style: TextStyle(color: isOpen ? Colors.white : isDone ? Colors.white60 : Colors.white30, fontWeight: FontWeight.w900, fontSize: 12)),
                  ]),
                ),
              ),
            );
          },
        )),
      ]),
    );
  }
}

class EndlessQuizPage extends StatefulWidget {
  final Future<void> Function(int) onEarn;
  const EndlessQuizPage({super.key, required this.onEarn});
  @override
  State<EndlessQuizPage> createState() => _EndlessQuizPageState();
}

class _EndlessQuizPageState extends State<EndlessQuizPage> {
  final math.Random random = math.Random();
  late Q current;
  late String sessionId;
  int number = 1, score = 0, correct = 0, lifetimeAnswered = 0, bestScore = 0;
  int? selected;
  bool rewarded = false;
  String feedback = '';
  String difficulty = 'متوسط';

  @override
  void initState() {
    super.initState();
    sessionId = DateTime.now().microsecondsSinceEpoch.toString();
    current = makeQuestion();
    _loadEndlessStats();
  }

  Future<void> _loadEndlessStats() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      lifetimeAnswered = prefs.getInt('endless_total_answered') ?? 0;
      bestScore = prefs.getInt('endless_best_score') ?? 0;
    });
  }

  Q makeQuestion() {
    final int min = difficulty == 'سهل' ? 1 : difficulty == 'متوسط' ? 8 : 15;
    final int max = difficulty == 'سهل' ? 20 : difficulty == 'متوسط' ? 60 : 120;
    final a = min + random.nextInt(max - min + 1);
    final b = min + random.nextInt(max - min + 1);
    final op = random.nextInt(difficulty == 'صعب' ? 4 : 3);
    late int answer;
    late String symbol;
    if (op == 0) {
      answer = a + b;
      symbol = '+';
    } else if (op == 1) {
      final high = math.max(a, b), low = math.min(a, b);
      answer = high - low;
      symbol = '−';
    } else if (op == 2) {
      answer = a * b;
      symbol = '×';
    } else {
      answer = a;
      symbol = '÷';
    }
    final left = op == 3 ? a * b : a;
    final right = b;
    final options = <int>{answer};
    while (options.length < 4) {
      final delta = 1 + random.nextInt(math.max(5, answer.abs() ~/ 3 + 5));
      final candidate = random.nextBool() ? answer + delta : math.max(0, answer - delta);
      options.add(candidate);
    }
    final choices = options.map((v) => v.toString()).toList()..shuffle(random);
    return Q('كم ناتج $left $symbol $right ؟', choices, choices.indexOf(answer.toString()));
  }

  Future<void> choose(int value) async {
    if (selected != null) return;
    setState(() => selected = value);
    final prefs = await SharedPreferences.getInstance();
    lifetimeAnswered = (prefs.getInt('endless_total_answered') ?? 0) + 1;
    await prefs.setInt('endless_total_answered', lifetimeAnswered);
    if (value == current.answer) {
      await AppFeedback.play(SoundCue.correct);
      correct++;
      score += 5;
      if (score > bestScore) {
        bestScore = score;
        await prefs.setInt('endless_best_score', bestScore);
      }
      final first = await awardOnce('endless_${sessionId}_$number', 5, widget.onEarn);
      if (mounted) setState(() {
        rewarded = first;
        feedback = first ? 'إجابة صحيحة! +5 نقاط' : 'إجابة صحيحة!';
      });
    } else {
      await AppFeedback.play(SoundCue.wrong);
      setState(() => feedback = 'الإجابة الصحيحة: ${current.choices[current.answer]}');
    }
  }

  void next() {
    setState(() {
      number++;
      current = makeQuestion();
      selected = null;
      rewarded = false;
      feedback = '';
    });
  }

  @override
  Widget build(BuildContext context) => Scaffold(backgroundColor: const Color(0xFF102C3C), 
    appBar: AppBar(backgroundColor: const Color(0xFF155B78), foregroundColor: const Color(0xFF8BD9FF), title: const Text('التحدي المفتوح')),
    body: ListView(padding: const EdgeInsets.all(18), children: [
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [Color(0xFF176247), deep]),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: gold.withOpacity(.6)),
        ),
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('جولات متجددة', style: TextStyle(color: gold, fontWeight: FontWeight.bold)),
            Text('السؤال رقم $number • بلا نهاية', style: const TextStyle(fontSize: 21, fontWeight: FontWeight.bold)),
          ]),
          Column(children: [
            const Icon(Icons.stars, color: gold, size: 28),
            Text('$score نقطة', style: const TextStyle(color: gold, fontWeight: FontWeight.bold)),
          Text('أفضل نتيجة: $bestScore', style: const TextStyle(color: Colors.white70, fontSize: 11)),
          ]),
        ]),
      ),
      const SizedBox(height: 14),
      const Text('اختر مستوى الصعوبة'),
      const SizedBox(height: 8),
      SegmentedButton<String>(
        segments: const [
          ButtonSegment(value: 'سهل', label: Text('سهل')),
          ButtonSegment(value: 'متوسط', label: Text('متوسط')),
          ButtonSegment(value: 'صعب', label: Text('صعب')),
        ],
        selected: {difficulty},
        onSelectionChanged: (values) => setState(() {
          difficulty = values.first;
          current = makeQuestion();
          selected = null;
          feedback = '';
        }),
      ),
      const SizedBox(height: 24),
      Container(
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(color: panel, borderRadius: BorderRadius.circular(20)),
        child: Column(children: [
          const Icon(Icons.psychology_alt, color: gold, size: 42),
          const SizedBox(height: 12),
          Text(current.text, textAlign: TextAlign.center, style: const TextStyle(fontSize: 27, fontWeight: FontWeight.bold)),
        ]),
      ),
      const SizedBox(height: 16),
      ...List.generate(current.choices.length, (i) => Padding(
        padding: const EdgeInsets.only(bottom: 9),
        child: OutlinedButton(
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.all(17),
            backgroundColor: selected != null && i == current.answer ? green : Colors.transparent,
            side: BorderSide(color: selected != null && i == current.answer ? gold : Colors.white24),
          ),
          onPressed: selected == null ? () => choose(i) : null,
          child: Text(current.choices[i], style: const TextStyle(fontSize: 18)),
        ),
      )),
      if (feedback.isNotEmpty) Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Text(feedback, textAlign: TextAlign.center, style: const TextStyle(color: gold, fontWeight: FontWeight.bold)),
      ),
      FilledButton.icon(
        onPressed: selected == null ? null : next,
        icon: const Icon(Icons.skip_next),
        label: const Text('السؤال التالي'),
      ),
      const SizedBox(height: 8),
      Text('إجابات صحيحة: $correct • أجبت عن $lifetimeAnswered سؤالاً إجمالاً. تُنشأ مسائل جديدة تلقائياً بلا حد عملياً، وتُحفظ إحصاءاتك على هذا الجهاز.', textAlign: TextAlign.center, style: const TextStyle(color: Colors.white60, fontSize: 12)),
    ]),
  );
}

class QuizPlayPage extends StatefulWidget {
  final String title, levelKey;
  final List<Q> questions;
  final int? questionLimit, stageNumber;
  final Future<void> Function(int) onEarn;
  const QuizPlayPage({super.key, required this.title, required this.questions, required this.levelKey, required this.onEarn, this.questionLimit, this.stageNumber});
  @override
  State<QuizPlayPage> createState() => _QuizPlayPageState();
}
class _QuizPlayPageState extends State<QuizPlayPage> {
  late List<int> order;
  int index = 0, score = 0;
  int? selected;
  bool finished = false, ready = false, blocked = false;
  String feedback = '';
  @override
  void initState() { super.initState(); order = []; _loadProgress(); }
  Future<void> _loadProgress() async {
    final prefs = await SharedPreferences.getInstance();
    if (widget.stageNumber != null) {
      final completed = prefs.getInt('completed_${widget.levelKey}') ?? 0;
      if (widget.stageNumber! <= completed || widget.stageNumber! != completed + 1) {
        if (mounted) setState(() { blocked = true; ready = true; });
        return;
      }
      final indices = List<int>.generate(widget.questions.length, (i) => i);
      indices.shuffle(math.Random(widget.stageNumber! * 7919));
      order = indices.take(math.min(10, indices.length)).toList();
      if (order.length < 10 && indices.isNotEmpty) {
        final random = math.Random(widget.stageNumber! * 104729);
        while (order.length < 10) { order.add(indices[random.nextInt(indices.length)]); }
      }
    } else {
      final unseen = await loadUnseenOrder('seen_quiz_${widget.levelKey}', widget.questions.length);
      order = widget.questionLimit == null ? unseen : unseen.take(widget.questionLimit!).toList();
    }
    if (!mounted) return;
    setState(() => ready = true);
  }
  Q get current => widget.questions[order[index]];
  Future<void> choose(int n) async {
    if (selected != null || finished || blocked) return;
    setState(() => selected = n);
    if (widget.stageNumber == null) await markItemSeen('seen_quiz_${widget.levelKey}', order[index]);
    if (n == current.answer) {
      await AppFeedback.play(SoundCue.correct);
      score += 10;
      final eventId = widget.stageNumber == null
          ? 'quiz_${widget.levelKey}_${order[index]}'
          : 'stage_${widget.levelKey}_${widget.stageNumber}_${index + 1}';
      final first = await awardOnce(eventId, 10, widget.onEarn);
      if (mounted) setState(() => feedback = first ? 'إجابة صحيحة! +10 نقاط.' : 'إجابة صحيحة!');
    } else {
      await AppFeedback.play(SoundCue.wrong);
      if (mounted) setState(() => feedback = 'الإجابة الصحيحة: ${current.choices[current.answer]}');
    }
  }
  Future<void> next() async {
    if (index == order.length - 1) {
      if (widget.stageNumber != null) {
        final prefs = await SharedPreferences.getInstance();
        final completed = prefs.getInt('completed_${widget.levelKey}') ?? 0;
        if (widget.stageNumber == completed + 1) {
          await prefs.setInt('completed_${widget.levelKey}', widget.stageNumber!);
        }
      }
      await AppFeedback.play(SoundCue.win);
      if (mounted) setState(() => finished = true);
    } else {
      setState(() { index++; selected = null; feedback = ''; });
    }
  }
  @override
  Widget build(BuildContext context) {
    if (!ready) return const Scaffold(backgroundColor: Color(0xFF1B2442), body: Center(child: CircularProgressIndicator()));
    if (blocked) return Scaffold(backgroundColor: const Color(0xFF1B2442), appBar: AppBar(title: Text(widget.title)), body: Center(child: Padding(padding: const EdgeInsets.all(24), child: Column(mainAxisSize: MainAxisSize.min, children: [
      const Icon(Icons.lock_rounded, color: gold, size: 64),
      const SizedBox(height: 12),
      const Text('هذه المرحلة مقفلة', style: TextStyle(fontSize: 23, fontWeight: FontWeight.w900)),
      const SizedBox(height: 8),
      const Text('أكمل المرحلة المفتوحة أولاً. المراحل المكتملة لا يمكن فتحها مرة أخرى.', textAlign: TextAlign.center),
      const SizedBox(height: 16),
      FilledButton(onPressed: () => Navigator.pop(context), child: const Text('العودة للمراحل')),
    ]))));
    return Scaffold(
      backgroundColor: const Color(0xFF111D30),
      appBar: AppBar(backgroundColor: const Color(0xFF243F70), foregroundColor: const Color(0xFFDCE7FF), title: Text(widget.title)),
      body: Padding(padding: const EdgeInsets.all(18), child: finished
        ? Center(child: Container(
            width: double.infinity, padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF315B79), Color(0xFF20294B)]), borderRadius: BorderRadius.circular(25), border: Border.all(color: gold.withOpacity(.55))),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              const Icon(Icons.workspace_premium_rounded, color: gold, size: 72),
              const SizedBox(height: 12),
              const Text('أُغلقت المرحلة بنجاح!', style: TextStyle(fontSize: 23, fontWeight: FontWeight.w900)),
              Text('المرحلة ${widget.stageNumber ?? ''} • نتيجتك: $score من ${order.length * 10}', textAlign: TextAlign.center),
              const SizedBox(height: 8),
              const Text('تم حفظ إنجازك. المرحلة التالية أصبحت متاحة.', style: TextStyle(color: Colors.white70)),
              const SizedBox(height: 16),
              FilledButton.icon(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.lock_rounded), label: const Text('العودة إلى خريطة المراحل')),
            ]),
          ))
        : Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Row(children: [
              Expanded(child: Text(widget.stageNumber == null ? 'السؤال ${index + 1} / ${order.length}' : 'المرحلة ${widget.stageNumber} • السؤال ${index + 1} من 10', style: const TextStyle(color: gold, fontWeight: FontWeight.bold))),
              Text('+$score نقطة', style: const TextStyle(color: gold, fontWeight: FontWeight.bold)),
            ]),
            const SizedBox(height: 10),
            ClipRRect(borderRadius: BorderRadius.circular(10), child: LinearProgressIndicator(minHeight: 9, value: (index + 1) / order.length, color: gold, backgroundColor: panel)),
            const SizedBox(height: 22),
            Container(padding: const EdgeInsets.all(22), decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF263D63), Color(0xFF1B2945)]), borderRadius: BorderRadius.circular(22), border: Border.all(color: Colors.white12)), child: Text(current.text, textAlign: TextAlign.center, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, height: 1.55))),
            const SizedBox(height: 18),
            ...List.generate(current.choices.length, (i) => Padding(padding: const EdgeInsets.only(bottom: 9), child: OutlinedButton(
              style: OutlinedButton.styleFrom(padding: const EdgeInsets.all(16), side: BorderSide(color: selected != null && i == current.answer ? gold : Colors.white24), backgroundColor: selected != null && i == current.answer ? green : const Color(0xFF1B2945)),
              onPressed: selected == null ? () => choose(i) : null,
              child: Align(alignment: Alignment.centerRight, child: Text(current.choices[i], style: const TextStyle(fontSize: 15))),
            ))),
            if (feedback.isNotEmpty) Padding(padding: const EdgeInsets.symmetric(vertical: 8), child: Text(feedback, style: const TextStyle(color: gold, fontWeight: FontWeight.bold))),
            const Spacer(),
            FilledButton.icon(onPressed: selected == null ? null : next, icon: Icon(index == order.length - 1 ? Icons.lock_rounded : Icons.arrow_back_rounded), label: Text(index == order.length - 1 ? 'إنهاء وإغلاق المرحلة' : 'السؤال التالي')),
          ]),
      ),
    );
  }
}

class Riddle {
  final String question, answer, hint;
  const Riddle(this.question, this.answer, this.hint);
}
const riddles = <Riddle>[
  Riddle('شيء كلما أخذت منه كبر، فما هو؟','الحفرة','تراه في الأرض ويزداد بالحفر.'),
  Riddle('له أسنان ولا يعض، ما هو؟','المشط','نستخدمه لترتيب الشعر.'),
  Riddle('يمشي بلا أرجل ويبكي بلا عيون، ما هو؟','السحاب','تراه في السماء وينزل منه المطر.'),
  Riddle('ما الشيء الذي يكتب ولا يقرأ؟','القلم','تستخدمه مع الدفتر.'),
  Riddle('بيت بلا أبواب ولا نوافذ، ما هو؟','البيضة','قشرته تحمي ما بداخله.'),
  Riddle('ما الشيء الذي له عين واحدة ولا يرى؟','الإبرة','نمرر الخيط من عينها.'),
  Riddle('كلما زاد نقص، ما هو؟','العمر','يمر مع مرور الأيام.'),
  Riddle('يسمع بلا أذن ويتكلم بلا لسان، ما هو؟','الهاتف','تحمله وتتحدث من خلاله.'),
  Riddle('شيء له أوراق وليس نباتاً وله جلد وليس حيواناً؟','الكتاب','نقرأ ما بداخله.'),
  Riddle('ما الشيء الذي يملأ الغرفة ولا يشغل مكاناً؟','الضوء','يأتي من الشمس أو المصباح.'),
  Riddle('ما الشيء الذي له رقبة وليس له رأس؟','الزجاجة','نضع فيها الماء.'),
  Riddle('ما الشيء الذي كلما مشى ترك أثراً وراءه؟','القلم','يترك خطوطاً على الورق.'),
  Riddle('ما الشيء الذي تراه في الماء ولا يبتل؟','الانعكاس','صورة تظهر على سطح الماء.'),
  Riddle('شيء له مفاتيح كثيرة ولا يفتح باباً؟','البيانو','آلة موسيقية.'),
  Riddle('ما الشيء الذي يسمعك صوتك؟','الصدى','يرجع الصوت من مكان بعيد.'),
];
class RiddlesPage extends StatefulWidget {
  final Future<void> Function(int) onEarn;
  const RiddlesPage({super.key, required this.onEarn});
  @override
  State<RiddlesPage> createState() => _RiddlesPageState();
}
class _RiddlesPageState extends State<RiddlesPage> {
  final input = TextEditingController();
  int index = 0;
  bool hint = false, revealed = false;
  String message = '';
  bool ready = false;
  @override
  void initState() { super.initState(); _loadNextUnseen(); }
  Future<void> _loadNextUnseen() async {
    final available = await loadUnseenOrder('seen_riddles', riddles.length);
    if (!mounted) return;
    setState(() { index = available.first; ready = true; input.clear(); hint = false; revealed = false; message = ''; });
  }
  @override
  void dispose() { input.dispose(); super.dispose(); }
  Future<void> check() async {
    if (!ready || revealed) return;
    final typed = cleanAnswer(input.text);
    if (typed.isEmpty) { setState(() => message = 'اكتب تخمينك أولاً.'); return; }
    final solution = cleanAnswer(riddles[index].answer);
    if (typed == solution) {
      await AppFeedback.play(SoundCue.correct);
      setState(() { revealed = true; message = 'إجابة صحيحة!'; });
      await markItemSeen('seen_riddles', index);
      final first = await awardOnce('riddle_' + index.toString(), 10, widget.onEarn);
      if (mounted) setState(() => message = first ? 'أحسنت! ربحت 10 نقاط.' : 'أحسنت! سبق احتساب نقاط هذا اللغز.');
    } else { await AppFeedback.play(SoundCue.wrong); setState(() => message = 'ليس هذا الحل. حاول مرة أخرى أو اطلب تلميحاً.'); }
  }
  Future<void> next() async {
    await markItemSeen('seen_riddles', index);
    final available = await loadUnseenOrder('seen_riddles', riddles.length);
    if (!mounted) return;
    setState(() { index = available.first; input.clear(); hint = false; revealed = false; message = ''; });
  }
  @override
  Widget build(BuildContext context) => !ready
    ? const Scaffold(backgroundColor: Color(0xFF2C1C3D), body: Center(child: CircularProgressIndicator()))
    : Scaffold(backgroundColor: const Color(0xFF2C1C3D), 
    appBar: AppBar(backgroundColor: const Color(0xFF623B79), foregroundColor: const Color(0xFFE0B6FF), title: const Text('ألغاز وذكاء')),
    body: ListView(padding: const EdgeInsets.all(18), children: [
      Text('لغز ' + (index + 1).toString() + ' من ' + riddles.length.toString(), style: const TextStyle(color: gold)),
      const SizedBox(height: 14),
      Container(padding: const EdgeInsets.all(22), decoration: BoxDecoration(color: panel, borderRadius: BorderRadius.circular(22), border: Border.all(color: gold.withOpacity(.45))), child: Column(children: [
        const Icon(Icons.lightbulb_circle_outlined, color: gold, size: 54),
        const SizedBox(height: 12),
        Text(riddles[index].question, textAlign: TextAlign.center, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, height: 1.6)),
      ])),
      const SizedBox(height: 16),
      TextField(controller: input, textInputAction: TextInputAction.done, onSubmitted: (_) => check(), decoration: const InputDecoration(labelText: 'اكتب إجابتك هنا', prefixIcon: Icon(Icons.edit))),
      const SizedBox(height: 10),
      FilledButton.icon(onPressed: check, icon: const Icon(Icons.check_circle_outline), label: const Text('تحقق من الإجابة')),
      OutlinedButton.icon(onPressed: () => setState(() => hint = true), icon: const Icon(Icons.tips_and_updates), label: const Text('أعطني تلميحاً')),
      if (hint) Card(color: green, child: Padding(padding: const EdgeInsets.all(14), child: Text(riddles[index].hint))),
      if (revealed) Card(child: ListTile(leading: const Icon(Icons.verified, color: gold), title: Text('الحل: ' + riddles[index].answer))),
      if (message.isNotEmpty) Padding(padding: const EdgeInsets.symmetric(vertical: 10), child: Text(message, style: const TextStyle(color: gold))),
      OutlinedButton(onPressed: next, child: const Text('اللغز التالي')),
    ]),
  );
}

class WordPuzzle {
  final String word, hint1, hint2, hint3;
  const WordPuzzle(this.word, this.hint1, this.hint2, this.hint3);
}
const words = <WordPuzzle>[
  WordPuzzle('مفتاح','نستخدمه لفتح شيء مغلق.','قد يكون معدنياً وله أسنان صغيرة.','يوضع غالباً في القفل.'),
  WordPuzzle('مدرسة','مكان يذهب إليه الطلاب.','فيها فصول ومعلمون.','تبدأ بحرف الميم.'),
  WordPuzzle('برتقال','فاكهة معروفة.','لونها غالباً برتقالي.','عصيرها مشهور.'),
  WordPuzzle('ساعة','تخبرنا بالوقت.','قد تُلبس في اليد.','لها عقارب أو شاشة.'),
  WordPuzzle('مظلة','تحميك من المطر أو الشمس.','تُفتح فوق الرأس.','تُسمى أحياناً شمسية.'),
  WordPuzzle('طائرة','وسيلة نقل.','تسافر بها لمسافات بعيدة.','تطير في السماء.'),
  WordPuzzle('حاسوب','جهاز إلكتروني.','نستخدمه للعمل والتعلم.','قد يكون محمولاً أو مكتبياً.'),
  WordPuzzle('نافذة','توجد في الجدار.','تسمح بدخول الهواء والضوء.','ننظر من خلالها للخارج.'),
  WordPuzzle('قمر','جسم نراه في السماء ليلاً.','يعكس ضوء الشمس.','يظهر بأطوار مختلفة.'),
  WordPuzzle('مكتبة','مكان للكتب.','يمكن استعارة الكتب منها.','تبدأ بحرف الميم.'),
];
class GuessWordPage extends StatefulWidget {
  final Future<void> Function(int) onEarn;
  const GuessWordPage({super.key, required this.onEarn});
  @override
  State<GuessWordPage> createState() => _GuessWordPageState();
}
class _GuessWordPageState extends State<GuessWordPage> {
  final input = TextEditingController();
  int index = 0, hintLevel = 0;
  bool solved = false;
  String message = '';
  bool ready = false;
  @override
  void initState() { super.initState(); _loadNextUnseen(); }
  Future<void> _loadNextUnseen() async {
    final available = await loadUnseenOrder('seen_words', words.length);
    if (!mounted) return;
    setState(() { index = available.first; ready = true; hintLevel = 0; solved = false; message = ''; input.clear(); });
  }
  @override
  void dispose() { input.dispose(); super.dispose(); }
  Future<void> submit() async {
    if (!ready || solved) return;
    if (cleanAnswer(input.text) == cleanAnswer(words[index].word)) {
      await AppFeedback.play(SoundCue.correct);
      setState(() { solved = true; message = 'إجابة ممتازة!'; });
      await markItemSeen('seen_words', index);
      final points = hintLevel == 0 ? 15 : 10;
      final first = await awardOnce('word_' + index.toString(), points, widget.onEarn);
      if (mounted) setState(() => message = first ? 'صحيح! ربحت ' + points.toString() + ' نقطة.' : 'صحيح! سبق احتساب نقاط هذه الكلمة.');
    } else { await AppFeedback.play(SoundCue.wrong); setState(() => message = 'ليست الكلمة المطلوبة. حاول من جديد.'); }
  }
  String get hintText {
    if (hintLevel == 1) return words[index].hint1;
    if (hintLevel == 2) return words[index].hint2;
    if (hintLevel == 3) return words[index].hint3;
    return 'اطلب تلميحاً إذا احتجت إلى مساعدة.';
  }
  Future<void> next() async {
    await markItemSeen('seen_words', index);
    final available = await loadUnseenOrder('seen_words', words.length);
    if (!mounted) return;
    setState(() { index = available.first; hintLevel = 0; solved = false; message = ''; input.clear(); });
  }
  @override
  Widget build(BuildContext context) => !ready
    ? const Scaffold(backgroundColor: Color(0xFF352518), body: Center(child: CircularProgressIndicator()))
    : Scaffold(backgroundColor: const Color(0xFF352518), 
    appBar: AppBar(backgroundColor: const Color(0xFF765020), foregroundColor: const Color(0xFFFFD18A), title: const Text('خمن الكلمة')),
    body: ListView(padding: const EdgeInsets.all(18), children: [
      Container(padding: const EdgeInsets.all(22), decoration: BoxDecoration(borderRadius: BorderRadius.circular(22), gradient: const LinearGradient(colors: [Color(0xFF604A1E), deep])), child: Column(children: [
        const Icon(Icons.question_mark_rounded, color: gold, size: 54),
        const Text('ما الكلمة؟', style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Text('لغز ' + (index + 1).toString() + ' من ' + words.length.toString(), style: const TextStyle(color: Colors.white70)),
        const SizedBox(height: 16),
        Wrap(spacing: 6, children: List.generate(words[index].word.length, (i) => Container(width: 36, height: 44, alignment: Alignment.center, decoration: BoxDecoration(color: panel, borderRadius: BorderRadius.circular(8), border: Border.all(color: gold.withOpacity(.5))), child: Text(solved ? words[index].word[i] : '؟', style: const TextStyle(fontSize: 20, color: gold, fontWeight: FontWeight.bold))))),
      ])),
      const SizedBox(height: 14),
      Card(child: ListTile(leading: const Icon(Icons.tips_and_updates, color: gold), title: Text(hintText))),
      TextField(controller: input, enabled: !solved, textInputAction: TextInputAction.done, onSubmitted: (_) => submit(), decoration: const InputDecoration(labelText: 'اكتب الكلمة التي تتوقعها')),
      const SizedBox(height: 10),
      FilledButton(onPressed: solved ? null : submit, child: const Text('تأكيد التخمين')),
      OutlinedButton.icon(onPressed: solved || hintLevel == 3 ? null : () => setState(() { hintLevel++; message = ''; }), icon: const Icon(Icons.lightbulb_outline), label: Text('تلميح ' + hintLevel.toString() + '/3')),
      if (solved) Card(color: green, child: ListTile(leading: const Icon(Icons.check_circle, color: gold), title: Text('الكلمة: ' + words[index].word))),
      if (message.isNotEmpty) Padding(padding: const EdgeInsets.symmetric(vertical: 8), child: Text(message, style: const TextStyle(color: gold))),
      OutlinedButton(onPressed: next, child: const Text('كلمة جديدة')),
    ]),
  );
}

class ChallengesPage extends StatefulWidget {
  final Future<void> Function(int) onEarn;
  const ChallengesPage({super.key, required this.onEarn});
  @override
  State<ChallengesPage> createState() => _ChallengesPageState();
}
class _ChallengesPageState extends State<ChallengesPage> {
  final tasks = const [
    ['تحدي الضحكة','قل جملة عادية بصوت مذيع أخبار.','😂'],
    ['تحدي الذاكرة','اذكر خمسة أشياء لونها أخضر خلال 20 ثانية.','🧠'],
    ['تحدي الخيال','اختر اسماً مضحكاً لفريقك الخيالي.','💡'],
    ['تحدي السرعة','اذكر خمسة أسماء فواكه دون توقف.','⚡'],
    ['تحدي المجاملة','قل لشخص من العائلة كلمة طيبة وصادقة.','🌟'],
    ['تحدي التركيز','اكتب أسماء ثلاثة بلدان تبدأ بحرف الميم.','🎯'],
    ['تحدي الحروف','اذكر أربع كلمات تبدأ بآخر حرف من اسمك.','🔤'],
    ['تحدي الوصف','صف فاكهتك المفضلة دون ذكر اسمها.','🍊'],
    ['تحدي الحساب','احسب 25 + 37 ذهنياً.','➕'],
    ['تحدي القصة','اختر ثلاثة أشياء واخترع لها قصة قصيرة.','📖'],
    ['تحدي الامتنان','اكتب ثلاثة أشياء جميلة حدثت لك اليوم.','🌿'],
    ['تحدي الملاحظة','اذكر أربعة أشياء زرقاء حولك.','🔵'],
  ];
  bool done = false;
  late int today;
  late String dateKey;
  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    dateKey = now.year.toString() + '-' + now.month.toString().padLeft(2,'0') + '-' + now.day.toString().padLeft(2,'0');
    today = now.difference(DateTime(2024,1,1)).inDays.abs() % tasks.length;
    load();
  }
  Future<void> load() async {
    final p = await SharedPreferences.getInstance();
    if (mounted) setState(() => done = p.getBool('daily_done_' + dateKey) ?? false);
  }
  Future<void> complete() async {
    if (done) return;
    final first = await awardOnce('daily_' + dateKey, 20, widget.onEarn);
    final p = await SharedPreferences.getInstance();
    await p.setBool('daily_done_' + dateKey, true);
    if (mounted) setState(() => done = true);
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(first ? 'أحسنت! حصلت على 20 نقطة.' : 'تم تسجيل إنجاز اليوم.')));
  }
  @override
  Widget build(BuildContext context) {
    final t = tasks[today];
    return Scaffold(backgroundColor: const Color(0xFF3A2025), 
      appBar: AppBar(backgroundColor: const Color(0xFF813C4A), foregroundColor: const Color(0xFFFFB6C4), title: const Text('التحديات اليومية')),
      body: ListView(padding: const EdgeInsets.all(18), children: [
        Container(padding: const EdgeInsets.all(22), decoration: BoxDecoration(borderRadius: BorderRadius.circular(22), gradient: const LinearGradient(colors: [Color(0xFF164E3A), deep]), border: Border.all(color: gold.withOpacity(.7))), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('تحدي اليوم', style: TextStyle(color: gold, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(dateKey, style: const TextStyle(color: Colors.white70)),
          const SizedBox(height: 16),
          Text(t[2] + '  ' + t[0], style: const TextStyle(fontSize: 23, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Text(t[1], style: const TextStyle(fontSize: 17, height: 1.5)),
          const SizedBox(height: 16),
          const Text('20 نقطة عند الإنجاز', style: TextStyle(color: gold)),
          const SizedBox(height: 14),
          SizedBox(width: double.infinity, child: FilledButton.icon(onPressed: done ? null : complete, icon: Icon(done ? Icons.check_circle : Icons.flag), label: Text(done ? 'أنجزت تحدي اليوم' : 'تم الإنجاز'))),
        ])),
        const SizedBox(height: 18),
        const Text('تحديات إضافية', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        ...tasks.asMap().entries.where((e) => e.key != today).take(8).map((e) => Card(child: ListTile(leading: Text(e.value[2], style: const TextStyle(fontSize: 23)), title: Text(e.value[0]), subtitle: Text(e.value[1])))),
        const Text('التحديات اختيارية وآمنة وخفيفة.', style: TextStyle(color: Colors.white60, fontSize: 12)),
      ]),
    );
  }
}

class QuotesPage extends StatelessWidget {
  const QuotesPage({super.key});
  static const quotes = [
    'ابدأ من حيث أنت، واستخدم ما لديك، وافعل ما تستطيع.',
    'الكلمة الطيبة قد تصنع يوماً جميلاً لشخص لا تعرف ما يمر به.',
    'لا تقارن بدايتك بنهاية طريق شخص آخر.',
    'كل خطوة صغيرة تقرّبك من هدف كبير.',
    'الأخلاق الجميلة لا تحتاج إلى مناسبة.',
    'كن سبباً في ابتسامة، فالأثر الطيب يبقى.',
    'من جدّ وجد، ومن زرع حصد.',
    'الثقة بالله بداية كل طريق مطمئن.',
    'اجعل طموحك أكبر من خوفك.',
    'النجاح يحتاج صبراً وعملاً واستمراراً.',
    'لا تنتظر الفرصة المثالية؛ ابدأ بما تستطيع.',
    'العقل الهادئ يرى حلولاً لا يراها الغضب.',
    'الاحترام أجمل ما يتركه الإنسان في قلوب الآخرين.',
    'تعلم شيئاً جديداً كل يوم، ولو كان بسيطاً.',
    'الأمل بداية الطريق، والعمل هو الذي يكمله.',
  ];
  @override
  Widget build(BuildContext context) => Scaffold(backgroundColor: const Color(0xFF172D3D), 
    appBar: AppBar(backgroundColor: const Color(0xFF285875), foregroundColor: const Color(0xFFB8E7FF), title: const Text('عبارات جميلة')),
    body: ListView(padding: const EdgeInsets.all(16), children: [
      Container(padding: const EdgeInsets.all(18), decoration: BoxDecoration(color: panel, borderRadius: BorderRadius.circular(18)), child: const Text('كلمات تضيء يومك', style: TextStyle(fontSize: 22, color: gold, fontWeight: FontWeight.bold))),
      const SizedBox(height: 12),
      ...quotes.map((q) => Card(child: ListTile(
        leading: const Icon(Icons.format_quote, color: gold),
        title: Text(q, style: const TextStyle(height: 1.6)),
        trailing: IconButton(icon: const Icon(Icons.copy, color: gold), tooltip: 'نسخ العبارة', onPressed: () {
          Clipboard.setData(ClipboardData(text: q));
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم نسخ العبارة')));
        }),
      ))),
    ]),
  );
}

class MemoryPairsPage extends StatefulWidget {
  final Future<void> Function(int) onEarn;
  const MemoryPairsPage({super.key, required this.onEarn});
  @override
  State<MemoryPairsPage> createState() => _MemoryPairsPageState();
}

class _MemoryPairsPageState extends State<MemoryPairsPage> {
  static const symbols = ['🚀', '🎈', '🌟', '🍀', '🎨', '⚽'];
  late List<String> cards;
  final Set<int> matched = {};
  int? first;
  int moves = 0;
  bool locked = false;
  bool finished = false;

  @override
  void initState() { super.initState(); _restart(); }

  void _restart() {
    cards = [...symbols, ...symbols]..shuffle(math.Random());
    matched.clear();
    first = null;
    moves = 0;
    locked = false;
    finished = false;
  }

  Future<void> _flip(int i) async {
    if (locked || finished || matched.contains(i) || first == i) return;
    if (first == null) {
      setState(() => first = i);
      return;
    }
    final previous = first!;
    setState(() { first = i; moves++; });
    if (cards[previous] == cards[i]) {
      setState(() { matched.add(previous); matched.add(i); first = null; });
      await AppFeedback.play(SoundCue.correct);
      if (matched.length == cards.length) {
        final earned = await awardOnce('memory_pairs_complete', 20, widget.onEarn);
        if (!mounted) return;
        setState(() => finished = true);
        await AppFeedback.play(SoundCue.win);
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(earned ? 'أحسنت! ربحت 20 نقطة.' : 'أكملت اللعبة مرة أخرى!'),
        ));
      }
    } else {
      setState(() => locked = true);
      await AppFeedback.play(SoundCue.wrong);
      await Future<void>.delayed(const Duration(milliseconds: 650));
      if (!mounted) return;
      setState(() { first = null; locked = false; });
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: const Color(0xFF102B36),
    appBar: AppBar(
      backgroundColor: const Color(0xFF15566A),
      foregroundColor: const Color(0xFF8CE6E0),
      title: const Text('لعبة الذاكرة'),
      actions: [IconButton(onPressed: () => setState(_restart), icon: const Icon(Icons.refresh_rounded))],
    ),
    body: ListView(padding: const EdgeInsets.all(18), children: [
      Text('المحاولات: $moves', textAlign: TextAlign.center, style: const TextStyle(fontSize: 18, color: Color(0xFF8CE6E0))),
      const SizedBox(height: 14),
      GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: cards.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, crossAxisSpacing: 10, mainAxisSpacing: 10),
        itemBuilder: (context, i) {
          final shown = matched.contains(i) || first == i;
          return InkWell(
            onTap: () => _flip(i),
            borderRadius: BorderRadius.circular(18),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: shown
                  ? [const Color(0xFF287E83), const Color(0xFF17545F)]
                  : [const Color(0xFF24485A), const Color(0xFF183142)]),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: matched.contains(i) ? const Color(0xFF8CE6E0) : Colors.white24),
              ),
              child: Center(child: Text(shown ? cards[i] : '؟', style: const TextStyle(fontSize: 34))),
            ),
          );
        },
      ),
      const SizedBox(height: 16),
      if (finished) FilledButton(onPressed: () => setState(_restart), child: const Text('العب مرة أخرى'))
      else const Text('اقلب بطاقتين في كل مرة، وحاول العثور على جميع الأزواج.', textAlign: TextAlign.center),
    ]),
  );
}

class TrueFalsePage extends StatefulWidget {
  final Future<void> Function(int) onEarn;
  const TrueFalsePage({super.key, required this.onEarn});
  @override
  State<TrueFalsePage> createState() => _TrueFalsePageState();
}

class _TrueFalsePageState extends State<TrueFalsePage> {
  static const items = <(String, bool)>[
    ('الشمس نجم وليست كوكباً.', true),
    ('عدد أضلاع المربع خمسة.', false),
    ('القمر يعكس ضوء الشمس.', true),
    ('الخفاش من الطيور.', false),
    ('المحيط الهادئ أكبر محيطات الأرض.', true),
    ('العدد 11 عدد زوجي.', false),
    ('النحلة تصنع العسل.', true),
    ('الصوت ينتقل في الفراغ.', false),
    ('النباتات تقوم بالبناء الضوئي.', true),
    ('المريخ أكبر من المشتري.', false),
  ];
  int index = 0, score = 0;
  List<int> order = [];
  bool ready = false;
  bool? selected;
  bool finished = false;
  String feedback = '';

  @override
  void initState() { super.initState(); _loadQuestions(); }
  Future<void> _loadQuestions() async {
    final unseen = await loadUnseenOrder('seen_true_false', items.length);
    if (!mounted) return;
    setState(() { order = unseen; ready = true; });
  }

  Future<void> _answer(bool answer) async {
    if (selected != null || !ready) return;
    final correct = answer == items[order[index]].$2;
    setState(() {
      selected = answer;
      if (correct) score++;
      feedback = correct ? 'إجابة صحيحة!' : 'الإجابة الصحيحة: ' + (items[order[index]].$2 ? 'صح' : 'خطأ');
    });
    await AppFeedback.play(correct ? SoundCue.correct : SoundCue.wrong);
    await markItemSeen('seen_true_false', order[index]);
    if (correct) await awardOnce('true_false_' + order[index].toString(), 5, widget.onEarn);
  }

  void _next() {
    if (index == order.length - 1) {
      setState(() => finished = true);
      AppFeedback.play(SoundCue.win);
    } else {
      setState(() { index++; selected = null; feedback = ''; });
    }
  }

  @override
  Widget build(BuildContext context) => !ready
    ? const Scaffold(backgroundColor: Color(0xFF30202B), body: Center(child: CircularProgressIndicator()))
    : Scaffold(
    backgroundColor: const Color(0xFF30202B),
    appBar: AppBar(backgroundColor: const Color(0xFF813C4A), foregroundColor: const Color(0xFFFFC3C7), title: const Text('صح أم خطأ')),
    body: Padding(
      padding: const EdgeInsets.all(18),
      child: finished
        ? Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.emoji_events_rounded, color: Color(0xFFFFC3C7), size: 72),
            const Text('انتهى التحدي!', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            Text('نتيجتك: $score من ' + items.length.toString()),
            FilledButton(onPressed: () => Navigator.pop(context), child: const Text('العودة للألعاب')),
          ]))
        : Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            LinearProgressIndicator(value: (index + 1) / order.length, color: const Color(0xFFFF9AA5)),
            const SizedBox(height: 18),
            Text('السؤال ' + (index + 1).toString() + ' من ' + items.length.toString(), textAlign: TextAlign.center),
            const SizedBox(height: 20),
            Expanded(child: Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF713B52), Color(0xFF3A2739)]), borderRadius: BorderRadius.circular(24)),
              child: Center(child: Text(items[order[index]].$1, textAlign: TextAlign.center, style: const TextStyle(fontSize: 25, height: 1.5, fontWeight: FontWeight.bold))),
            )),
            const SizedBox(height: 16),
            Row(children: [
              Expanded(child: FilledButton(onPressed: selected == null ? () => _answer(true) : null, child: const Text('صح'))),
              const SizedBox(width: 12),
              Expanded(child: FilledButton(onPressed: selected == null ? () => _answer(false) : null, child: const Text('خطأ'))),
            ]),
            if (feedback.isNotEmpty) Padding(padding: const EdgeInsets.all(12), child: Text(feedback, textAlign: TextAlign.center)),
            FilledButton(onPressed: selected == null ? null : _next, child: Text(index == items.length - 1 ? 'عرض النتيجة' : 'السؤال التالي')),
          ]),
    ),
  );
}


class SpeedChallengePage extends StatefulWidget {
  final Future<void> Function(int) onEarn;
  const SpeedChallengePage({super.key, required this.onEarn});
  @override
  State<SpeedChallengePage> createState() => _SpeedChallengePageState();
}

class _SpeedChallengePageState extends State<SpeedChallengePage> {
  final math.Random random = math.Random();
  Timer? _timer;
  late final String _sessionId;
  late Q current;
  int seconds = 60, score = 0, answered = 0, bestScore = 0;
  int? selected;
  bool finished = false;
  bool saving = false;

  @override
  void initState() {
    super.initState();
    _sessionId = DateTime.now().microsecondsSinceEpoch.toString();
    current = _makeQuestion();
    _loadBest();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted || finished) { timer.cancel(); return; }
      if (seconds <= 1) {
        setState(() => seconds = 0);
        _finish();
      } else {
        setState(() => seconds--);
      }
    });
  }

  Future<void> _loadBest() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) setState(() => bestScore = prefs.getInt('speed_challenge_best') ?? 0);
  }

  Q _makeQuestion() {
    final a = 2 + random.nextInt(28);
    final b = 2 + random.nextInt(18);
    final op = random.nextInt(3);
    final answer = op == 0 ? a + b : op == 1 ? (a - b).abs() : a * b;
    final symbol = op == 0 ? '+' : op == 1 ? '−' : '×';
    final values = <int>{answer};
    while (values.length < 4) {
      final delta = 1 + random.nextInt(math.max(4, answer ~/ 4 + 4));
      values.add(random.nextBool() ? answer + delta : math.max(0, answer - delta));
    }
    final choices = values.map((v) => v.toString()).toList()..shuffle(random);
    return Q('كم ناتج $a $symbol $b ؟', choices, choices.indexOf(answer.toString()));
  }

  Future<void> _answer(int value) async {
    if (selected != null || finished) return;
    setState(() { selected = value; answered++; });
    final correct = value == current.answer;
    await AppFeedback.play(correct ? SoundCue.correct : SoundCue.wrong);
    if (correct) {
      score++;
      await awardOnce('speed_${_sessionId}_$answered', 3, widget.onEarn);
    }
    if (mounted) setState(() {});
  }

  void _next() {
    if (finished || selected == null) return;
    setState(() { current = _makeQuestion(); selected = null; });
  }

  Future<void> _finish() async {
    if (finished || saving) return;
    saving = true;
    _timer?.cancel();
    final prefs = await SharedPreferences.getInstance();
    if (score > bestScore) {
      bestScore = score;
      await prefs.setInt('speed_challenge_best', bestScore);
    }
    await prefs.setInt('speed_challenge_total', (prefs.getInt('speed_challenge_total') ?? 0) + answered);
    if (!mounted) return;
    setState(() { finished = true; saving = false; });
    await AppFeedback.play(SoundCue.win);
  }

  @override
  void dispose() { _timer?.cancel(); super.dispose(); }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: const Color(0xFF30202B),
    appBar: AppBar(backgroundColor: const Color(0xFF813C4A), foregroundColor: const Color(0xFFFFC3C7), title: const Text('تحدي 60 ثانية')),
    body: ListView(padding: const EdgeInsets.all(18), children: [
      Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF9C4855), Color(0xFF42283D)], begin: Alignment.topRight, end: Alignment.bottomLeft), borderRadius: BorderRadius.circular(24), border: Border.all(color: const Color(0xFFFFC3C7).withOpacity(.35))),
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
          _SpeedStat(label: 'الوقت', value: '$seconds', icon: Icons.timer_rounded),
          _SpeedStat(label: 'النقاط', value: '$score', icon: Icons.bolt_rounded),
          _SpeedStat(label: 'أفضل نتيجة', value: '$bestScore', icon: Icons.emoji_events_rounded),
        ]),
      ),
      const SizedBox(height: 12),
      ClipRRect(borderRadius: BorderRadius.circular(20), child: LinearProgressIndicator(value: seconds / 60, minHeight: 8, color: const Color(0xFFFFC3C7), backgroundColor: Colors.white12)),
      const SizedBox(height: 22),
      if (finished) ...[
        Container(padding: const EdgeInsets.all(24), decoration: BoxDecoration(color: const Color(0xFF492D43), borderRadius: BorderRadius.circular(24)), child: Column(children: [
          const Icon(Icons.emoji_events_rounded, color: Color(0xFFFFD36B), size: 66),
          const SizedBox(height: 10),
          const Text('انتهى الوقت!', style: TextStyle(fontSize: 25, fontWeight: FontWeight.w900)),
          const SizedBox(height: 8),
          Text('أجبت عن $answered سؤالاً، وأجبت بشكل صحيح عن $score.', textAlign: TextAlign.center, style: const TextStyle(color: Colors.white70, height: 1.5)),
          const SizedBox(height: 8),
          Text('أفضل نتيجة: $bestScore', style: const TextStyle(color: Color(0xFFFFC3C7), fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          FilledButton.icon(onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => SpeedChallengePage(onEarn: widget.onEarn))), icon: const Icon(Icons.refresh_rounded), label: const Text('العب مرة أخرى')),
        ])),
      ] else ...[
        Container(padding: const EdgeInsets.all(24), decoration: BoxDecoration(color: const Color(0xFF492D43), borderRadius: BorderRadius.circular(24)), child: Column(children: [
          const Icon(Icons.flash_on_rounded, color: Color(0xFFFFC3C7), size: 42),
          const SizedBox(height: 12),
          Text(current.text, textAlign: TextAlign.center, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900)),
        ])),
        const SizedBox(height: 14),
        ...List.generate(current.choices.length, (i) {
          final right = i == current.answer;
          final isSelected = selected == i;
          final color = selected == null ? const Color(0xFF563747) : right ? const Color(0xFF247A58) : isSelected ? const Color(0xFF9B454B) : const Color(0xFF563747);
          return Padding(padding: const EdgeInsets.only(bottom: 9), child: SizedBox(height: 54, child: FilledButton(
            style: FilledButton.styleFrom(backgroundColor: color, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
            onPressed: selected == null ? () => _answer(i) : null,
            child: Text(current.choices[i], style: const TextStyle(fontSize: 19, fontWeight: FontWeight.bold)),
          )));
        }),
        if (selected != null) FilledButton(onPressed: _next, child: const Text('السؤال التالي')),
        const SizedBox(height: 8),
        const Text('كل إجابة صحيحة تمنحك 3 نقاط داخل التطبيق. لا توجد خسارة نقاط عند الخطأ.', textAlign: TextAlign.center, style: TextStyle(color: Colors.white60, fontSize: 11)),
      ],
    ]),
  );
}

class _SpeedStat extends StatelessWidget {
  final String label, value;
  final IconData icon;
  const _SpeedStat({required this.label, required this.value, required this.icon});
  @override
  Widget build(BuildContext context) => Column(children: [
    Icon(icon, color: const Color(0xFFFFC3C7), size: 23),
    const SizedBox(height: 5),
    Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
    Text(label, style: const TextStyle(color: Colors.white70, fontSize: 10)),
  ]);
}

// بنك محلي يولّد 1,200 سؤال حسابي مختلف دون إنترنت.
List<Q> generatedQuestionBank() {
  final out = <Q>[];
  for (var a = 2; a <= 41 && out.length < 1200; a++) {
    for (var b = 2; b <= 41 && out.length < 1200; b++) {
      final ops = <(String, int)>[('+', a + b), ('-', (a - b).abs()), ('×', a * b)];
      for (final op in ops) {
        if (out.length >= 1200) break;
        final answer = op.$2;
        final values = <int>{answer};
        for (var d = 1; values.length < 4; d++) { values.add(answer + d); if (answer - d >= 0) values.add(answer - d); }
        final choices = values.take(4).map((v) => v.toString()).toList()..shuffle(math.Random(a * 10000 + b * 100 + answer));
        out.add(Q('احسب: ' + a.toString() + ' ' + op.$1 + ' ' + b.toString() + ' = ؟', choices, choices.indexOf(answer.toString())));
      }
    }
  }
  return out;
}

class WordMeaning { final String word, meaning; const WordMeaning(this.word, this.meaning); }
const wordMeanings = <WordMeaning>[
  WordMeaning('الشجاعة','الثبات عند مواجهة الصعوبات بحكمة'),
  WordMeaning('التواضع','عدم التكبر واحترام الآخرين'),
  WordMeaning('الأمانة','حفظ الحقوق وأداء ما اؤتمن عليه الإنسان'),
  WordMeaning('المثابرة','الاستمرار في المحاولة والعمل بجد'),
  WordMeaning('الفضول','الرغبة في المعرفة والاكتشاف'),
  WordMeaning('التأمل','التفكير الهادئ والعميق'),
  WordMeaning('الازدهار','النمو والتقدم وتحسن الحال'),
  WordMeaning('المبادرة','البدء بالفعل دون انتظار طلب'),
  WordMeaning('الإنصاف','إعطاء كل ذي حق حقه'),
  WordMeaning('الإبداع','ابتكار أفكار أو أعمال جديدة'),
  WordMeaning('التعاون','عمل أشخاص معاً لتحقيق هدف مشترك'),
  WordMeaning('المرونة','القدرة على التكيف مع التغيرات'),
  WordMeaning('الاستنتاج','الوصول إلى نتيجة اعتماداً على معلومات'),
  WordMeaning('المصداقية','كون الكلام جديراً بالثقة'),
  WordMeaning('الاستدامة','استخدام الموارد بما يحافظ عليها للمستقبل'),
  WordMeaning('الحصافة','حسن التصرف والتفكير السليم'),
  WordMeaning('الوجيز','قصير مع وضوح المعنى'),
  WordMeaning('الغزير','الكثير والوفير'),
  WordMeaning('الشاسع','الواسع جداً'),
  WordMeaning('المبهم','غير الواضح أو صعب الفهم'),
  WordMeaning('التراث','ما ورثه المجتمع من عادات وآثار ومعارف'),
  WordMeaning('المعجم','كتاب يشرح الكلمات ومعانيها'),
  WordMeaning('المنهج','خطة منظمة للوصول إلى هدف'),
  WordMeaning('الفرضية','تفسير مبدئي يحتاج إلى اختبار'),
  WordMeaning('الطاقة','القدرة على بذل شغل أو إحداث تغيير'),
  WordMeaning('الجاذبية','قوة تجذب الأجسام بعضها نحو بعض'),
  WordMeaning('الهضبة','أرض مرتفعة سطحها واسع'),
  WordMeaning('المناخ','متوسط أحوال الطقس خلال مدة طويلة'),
  WordMeaning('الموطن','المكان الطبيعي الذي يعيش فيه الكائن'),
  WordMeaning('التوازن','حالة من الاعتدال والاستقرار'),
  WordMeaning('الندرة','قلة وجود الشيء'),
  WordMeaning('الوفرة','كثرة وجود الشيء'),
  WordMeaning('المهارة','القدرة على أداء عمل بإتقان'),
  WordMeaning('التحليل','تقسيم الموضوع إلى عناصر لفهمه'),
  WordMeaning('التركيز','توجيه الانتباه إلى أمر محدد'),
];

class MeaningWordPage extends StatefulWidget {
  final Future<void> Function(int) onEarn;
  const MeaningWordPage({super.key, required this.onEarn});
  @override State<MeaningWordPage> createState() => _MeaningWordPageState();
}
class _MeaningWordPageState extends State<MeaningWordPage> {
  final random = math.Random();
  late List<int> order;
  late List<String> options;
  int index = 0, score = 0;
  int? selected;
  bool checked = false;
  WordMeaning get current => wordMeanings[order[index]];
  bool ready = false;
  @override void initState() { super.initState(); _loadNextUnseen(); }
  Future<void> _loadNextUnseen() async {
    final available = await loadUnseenOrder('seen_meanings', wordMeanings.length);
    if (!mounted) return;
    setState(() { order = available; index = 0; ready = true; _options(); });
  }
  void _options() { final set = <String>{current.meaning}; while (set.length < 4) { set.add(wordMeanings[random.nextInt(wordMeanings.length)].meaning); } options = set.toList()..shuffle(random); selected = null; checked = false; }
  Future<void> _confirm() async {
    if (selected == null || checked || !ready) return;
    final ok = options[selected!] == current.meaning;
    setState(() => checked = true);
    await AppFeedback.play(ok ? SoundCue.correct : SoundCue.wrong);
    await markItemSeen('seen_meanings', order[index]);
    if (ok) { score++; await awardOnce('meaning_word_' + order[index].toString(), 5, widget.onEarn); }
  }
  Future<void> _next() async {
    if (index == order.length - 1) {
      await _loadNextUnseen();
      if (!mounted) return;
      setState(() => score = 0);
    } else {
      setState(() { index++; _options(); });
    }
  }
  @override Widget build(BuildContext context) => !ready
    ? const Scaffold(backgroundColor: Color(0xFF17283D), body: Center(child: CircularProgressIndicator()))
    : Scaffold(
    backgroundColor: const Color(0xFF17283D),
    appBar: AppBar(backgroundColor: const Color(0xFF28558A), foregroundColor: const Color(0xFFB9D9FF), title: const Text('ما معنى الكلمة؟')),
    body: ListView(padding: const EdgeInsets.all(18), children: [
      Container(padding: const EdgeInsets.all(20), decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF28558A), Color(0xFF182C49)]), borderRadius: BorderRadius.circular(22)), child: Column(children: [
        const Icon(Icons.auto_stories_rounded, size: 44, color: Color(0xFFB9D9FF)),
        Text('الكلمة ' + (index + 1).toString() + ' من ' + order.length.toString()),
        Text(current.word, style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w900)),
      ])),
      const SizedBox(height: 18), const Text('اختر المعنى الصحيح:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      ...List.generate(options.length, (i) {
        final right = options[i] == current.meaning;
        final color = checked && right ? const Color(0xFF27865E) : checked && selected == i ? const Color(0xFF9B454B) : selected == i ? const Color(0xFF28558A) : const Color(0xFF24364D);
        return Padding(padding: const EdgeInsets.only(top: 9), child: InkWell(onTap: checked ? null : () => setState(() => selected = i), child: Container(padding: const EdgeInsets.all(15), decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(14)), child: Text(options[i]))));
      }),
      if (checked) Padding(padding: const EdgeInsets.all(12), child: Text(options[selected!] == current.meaning ? 'إجابة صحيحة! +5 نقاط' : 'الإجابة الصحيحة: ' + current.meaning, textAlign: TextAlign.center)),
      FilledButton(onPressed: checked ? _next : selected == null ? null : _confirm, child: Text(checked ? 'الكلمة التالية' : 'تأكيد الإجابة')),
      Text('نقاط الجولة: ' + score.toString(), textAlign: TextAlign.center),
    ]),
  );
}
