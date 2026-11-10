import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

const _gold = Color(0xFFE0B84F);
const _green = Color(0xFF0B3D2E);
const _panel = Color(0xFF102B22);

class QuizPage extends StatefulWidget {
  final Future<void> Function(int) onEarn;
  const QuizPage({super.key, required this.onEarn});
  @override
  State<QuizPage> createState() => _QuizPageState();
}
class _QuizPageState extends State<QuizPage> {
  final questions = const [
    ['ما عاصمة اليمن؟', 'صنعاء', 'عدن', 'تعز', 'إب', '0'],
    ['كم عدد أيام الأسبوع؟', '5', '6', '7', '8', '2'],
    ['ما الكوكب المعروف بالكوكب الأحمر؟', 'الزهرة', 'المريخ', 'زحل', 'عطارد', '1'],
    ['ما أكبر محيط على الأرض؟', 'الأطلسي', 'الهندي', 'المتجمد', 'الهادئ', '3'],
    ['كم يساوي 9 × 7؟', '56', '63', '72', '69', '1'],
    ['كم ضلعاً للمثلث؟', '2', '3', '4', '5', '1'],
  ];
  int index = 0, score = 0;
  int? selected;
  bool finished = false;
  void answer(int i) {
    if (selected != null) return;
    setState(() => selected = i);
    if (i == int.parse(questions[index][5])) {
      score += 10;
      widget.onEarn(10);
    }
  }
  void next() {
    if (index == questions.length - 1) {
      setState(() => finished = true);
    } else {
      setState(() { index++; selected = null; });
    }
  }
  void restart() => setState(() { index = 0; score = 0; selected = null; finished = false; });
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('اختبارات وأسئلة')),
    body: Padding(
      padding: const EdgeInsets.all(18),
      child: finished
        ? Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.emoji_events, color: _gold, size: 68),
            const Text('أحسنت! انتهى الاختبار', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            Text('نتيجتك: ' + score.toString() + ' نقطة'),
            const SizedBox(height: 18),
            FilledButton(onPressed: restart, child: const Text('إعادة الاختبار')),
          ]))
        : Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            LinearProgressIndicator(value: (index + 1) / questions.length, color: _gold),
            const SizedBox(height: 16),
            Text('السؤال ' + (index + 1).toString() + ' من ' + questions.length.toString(), style: const TextStyle(color: _gold)),
            const SizedBox(height: 12),
            Text(questions[index][0], style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 18),
            ...List.generate(4, (i) => Padding(
              padding: const EdgeInsets.only(bottom: 9),
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.all(15),
                  side: BorderSide(color: selected != null && i == int.parse(questions[index][5]) ? _gold : Colors.white24),
                  backgroundColor: selected != null && i == int.parse(questions[index][5]) ? _green : Colors.transparent,
                ),
                onPressed: () => answer(i),
                child: Align(alignment: Alignment.centerRight, child: Text(questions[index][i + 1])),
              ),
            )),
            if (selected != null)
              Text(selected == int.parse(questions[index][5]) ? 'إجابة صحيحة! +10 نقاط' : 'إجابة غير صحيحة، حاول في السؤال التالي.', style: const TextStyle(color: _gold)),
            const Spacer(),
            FilledButton(onPressed: selected == null ? null : next, child: Text(index == questions.length - 1 ? 'عرض النتيجة' : 'السؤال التالي')),
          ]),
    ),
  );
}

class ChallengesPage extends StatefulWidget {
  final Future<void> Function(int) onEarn;
  const ChallengesPage({super.key, required this.onEarn});
  @override
  State<ChallengesPage> createState() => _ChallengesPageState();
}
class _ChallengesPageState extends State<ChallengesPage> {
  final completed = <int>{};
  final tasks = const [
    ['تحدي الضحكة', 'قل جملة عادية بصوت مذيع أخبار.', '😂'],
    ['تحدي الذاكرة', 'اذكر خمسة أشياء لونها أخضر خلال 20 ثانية.', '🧠'],
    ['تحدي الخيال', 'اختر اسماً مضحكاً لفريقك الخيالي.', '💡'],
    ['تحدي السرعة', 'اذكر خمسة أسماء فواكه دون توقف.', '⚡'],
    ['تحدي المجاملة', 'قل لشخص من العائلة كلمة طيبة وصادقة.', '🌟'],
    ['تحدي التركيز', 'اكتب أسماء ثلاثة بلدان تبدأ بحرف الميم.', '🎯'],
  ];
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('تحديات مضحكة')),
    body: ListView(padding: const EdgeInsets.all(16), children: [
      const Text('أنجز التحدي واضغط الزر لتحصل على 5 نقاط.', style: TextStyle(color: _gold)),
      const SizedBox(height: 10),
      ...List.generate(tasks.length, (i) => Card(child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(tasks[i][2] + '  ' + tasks[i][0], style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(tasks[i][1]),
          const SizedBox(height: 10),
          Align(alignment: Alignment.centerLeft, child: FilledButton(
            onPressed: completed.contains(i) ? null : () {
              setState(() => completed.add(i));
              widget.onEarn(5);
            },
            child: Text(completed.contains(i) ? 'تم الإنجاز ✓' : 'أنجزت +5 نقاط'),
          )),
        ]),
      ))),
      const Text('التحديات اختيارية، ونفّذها بطريقة آمنة ومناسبة.', style: TextStyle(color: Colors.white60, fontSize: 12)),
    ]),
  );
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
  ];
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('عبارات جميلة')),
    body: ListView(padding: const EdgeInsets.all(16), children: [
      const Text('كلمات قصيرة ليوم أجمل', style: TextStyle(color: _gold, fontSize: 18, fontWeight: FontWeight.bold)),
      const SizedBox(height: 10),
      ...quotes.map((q) => Card(child: ListTile(
        leading: const Icon(Icons.format_quote, color: _gold),
        title: Text(q, style: const TextStyle(height: 1.6)),
        trailing: IconButton(
          icon: const Icon(Icons.copy, color: _gold),
          tooltip: 'نسخ العبارة',
          onPressed: () {
            Clipboard.setData(ClipboardData(text: q));
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم نسخ العبارة')));
          },
        ),
      ))),
    ]),
  );
}
