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
String cleanAnswer(String s) => s.trim().toLowerCase()
  .replaceAll(RegExp(r'[\u064B-\u065F\u0670]'), '')
  .replaceAll('أ', 'ا').replaceAll('إ', 'ا').replaceAll('آ', 'ا')
  .replaceAll('ى', 'ي').replaceAll(RegExp(r'\s+'), '');

class GamesHubPage extends StatelessWidget {
  final Future<void> Function(int) onEarn;
  const GamesHubPage({super.key, required this.onEarn});
  @override
  Widget build(BuildContext context) {
    final games = [
      ['اختبارات المعلومات', 'ثلاثة مستويات: سهل ومتوسط وصعب', Icons.quiz, const Color(0xFF48B887), () => Navigator.push(context, MaterialPageRoute(builder: (_) => QuizLevelsPage(onEarn: onEarn)))],
      ['ألغاز وذكاء', 'ألغاز كثيرة مع تلميحات وكشف الحل', Icons.psychology_alt, const Color(0xFF9B83E8), () => Navigator.push(context, MaterialPageRoute(builder: (_) => RiddlesPage(onEarn: onEarn)))],
      ['خمن الكلمة', 'اكتشف الكلمة من التلميحات', Icons.lightbulb, const Color(0xFFD49A39), () => Navigator.push(context, MaterialPageRoute(builder: (_) => GuessWordPage(onEarn: onEarn)))],
    ];
    return Scaffold(
      appBar: AppBar(title: const Text('الألعاب والتحديات')),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: const LinearGradient(colors: [Color(0xFF176247), deep], begin: Alignment.topRight, end: Alignment.bottomLeft),
            border: Border.all(color: gold.withOpacity(.7)),
          ),
          child: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('ALQOUD • GAME ZONE', style: TextStyle(color: gold, letterSpacing: 1.5, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Text('فكّر، خمن، واكتشف!', style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold)),
            SizedBox(height: 7),
            Text('كل يوم فرصة جديدة لتجربة لعبة وتحدي نفسك.'),
          ]),
        ),
        const SizedBox(height: 18),
        ...games.map((g) => Card(
          color: panel,
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: CircleAvatar(backgroundColor: (g[3] as Color).withOpacity(.18), child: Icon(g[2] as IconData, color: g[3] as Color)),
            title: Text(g[0] as String, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(g[1] as String),
            trailing: const Icon(Icons.arrow_back_ios_new, color: gold, size: 17),
            onTap: g[4] as VoidCallback,
          ),
        )),
        const SizedBox(height: 8),
        const Text('النقاط رصيد إنجاز داخل التطبيق فقط، وليست أموالاً ولا تُستخدم للمراهنة.', style: TextStyle(color: Colors.white60, fontSize: 12)),
      ]),
    );
  }
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
    final levels = [
      ['سهل','ابدأ بالإحماء',Icons.sentiment_satisfied,easy,Color(0xFF48B887)],
      ['متوسط','اختبر معلوماتك',Icons.psychology,medium,Color(0xFFE0B84F)],
      ['صعب','تحدَّ معلوماتك',Icons.local_fire_department,hard,Color(0xFFE47A58)],
    ];
    return Scaffold(
      appBar: AppBar(title: const Text('مستويات الاختبار')),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        const Text('كل إجابة صحيحة تمنحك 10 نقاط لأول مرة.', style: TextStyle(color: gold)),
        const SizedBox(height: 12),
        ...levels.map((l) => Card(color: panel, child: ListTile(
          contentPadding: const EdgeInsets.all(16),
          leading: CircleAvatar(backgroundColor: (l[4] as Color).withOpacity(.18), child: Icon(l[2] as IconData, color: l[4] as Color)),
          title: Text(l[0] as String, style: const TextStyle(fontSize: 19, fontWeight: FontWeight.bold)),
          subtitle: Text((l[1] as String) + ' • 10 أسئلة'),
          trailing: const Icon(Icons.play_circle_fill, color: gold, size: 30),
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => QuizPlayPage(title: 'اختبار ' + (l[0] as String), questions: l[3] as List<Q>, levelKey: l[0] as String, onEarn: onEarn))),
        ))),
      ]),
    );
  }
}

class QuizPlayPage extends StatefulWidget {
  final String title, levelKey;
  final List<Q> questions;
  final Future<void> Function(int) onEarn;
  const QuizPlayPage({super.key, required this.title, required this.questions, required this.levelKey, required this.onEarn});
  @override
  State<QuizPlayPage> createState() => _QuizPlayPageState();
}
class _QuizPlayPageState extends State<QuizPlayPage> {
  late List<int> order;
  int index = 0, score = 0;
  int? selected;
  bool finished = false;
  String feedback = '';
  @override
  void initState() { super.initState(); order = List.generate(widget.questions.length, (i) => i)..shuffle(); }
  Q get current => widget.questions[order[index]];
  Future<void> choose(int n) async {
    if (selected != null) return;
    setState(() => selected = n);
    if (n == current.answer) {
      score += 10;
      final first = await awardOnce('quiz_' + widget.levelKey + '_' + order[index].toString(), 10, widget.onEarn);
      if (mounted) setState(() => feedback = first ? 'صحيح! ربحت 10 نقاط.' : 'إجابة صحيحة! سبق احتساب نقاط هذا السؤال.');
    } else {
      setState(() => feedback = 'الإجابة الصحيحة: ' + current.choices[current.answer]);
    }
  }
  void next() {
    if (index == order.length - 1) { setState(() => finished = true); }
    else { setState(() { index++; selected = null; feedback = ''; }); }
  }
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(widget.title)),
    body: Padding(padding: const EdgeInsets.all(18), child: finished
      ? Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.emoji_events, color: gold, size: 72),
          const SizedBox(height: 10),
          const Text('انتهى الاختبار!', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          Text('نتيجتك: ' + score.toString() + ' من ' + (order.length * 10).toString()),
          const SizedBox(height: 16),
          FilledButton(onPressed: () => Navigator.pop(context), child: const Text('العودة للمستويات')),
        ]))
      : Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          ClipRRect(borderRadius: BorderRadius.circular(10), child: LinearProgressIndicator(minHeight: 8, value: (index + 1) / order.length, color: gold, backgroundColor: panel)),
          const SizedBox(height: 16),
          Text('السؤال ' + (index + 1).toString() + ' / ' + order.length.toString(), style: const TextStyle(color: gold)),
          const SizedBox(height: 12),
          Text(current.text, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, height: 1.5)),
          const SizedBox(height: 18),
          ...List.generate(4, (i) => Padding(padding: const EdgeInsets.only(bottom: 9), child: OutlinedButton(
            style: OutlinedButton.styleFrom(padding: const EdgeInsets.all(16), side: BorderSide(color: selected != null && i == current.answer ? gold : Colors.white24), backgroundColor: selected != null && i == current.answer ? green : Colors.transparent),
            onPressed: () => choose(i),
            child: Align(alignment: Alignment.centerRight, child: Text(current.choices[i])),
          ))),
          if (feedback.isNotEmpty) Padding(padding: const EdgeInsets.symmetric(vertical: 8), child: Text(feedback, style: const TextStyle(color: gold))),
          const Spacer(),
          FilledButton(onPressed: selected == null ? null : next, child: Text(index == order.length - 1 ? 'إنهاء الاختبار' : 'السؤال التالي')),
        ])),
  );
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
  @override
  void dispose() { input.dispose(); super.dispose(); }
  Future<void> check() async {
    final typed = cleanAnswer(input.text);
    if (typed.isEmpty) { setState(() => message = 'اكتب تخمينك أولاً.'); return; }
    final solution = cleanAnswer(riddles[index].answer);
    if (typed == solution || (solution.contains(typed) && typed.length >= 3)) {
      setState(() { revealed = true; message = 'إجابة صحيحة!'; });
      final first = await awardOnce('riddle_' + index.toString(), 10, widget.onEarn);
      if (mounted) setState(() => message = first ? 'أحسنت! ربحت 10 نقاط.' : 'أحسنت! سبق احتساب نقاط هذا اللغز.');
    } else { setState(() => message = 'ليس هذا الحل. حاول مرة أخرى أو اطلب تلميحاً.'); }
  }
  void next() { setState(() { index = (index + 1) % riddles.length; input.clear(); hint = false; revealed = false; message = ''; }); }
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('ألغاز وذكاء')),
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
  @override
  void dispose() { input.dispose(); super.dispose(); }
  Future<void> submit() async {
    if (cleanAnswer(input.text) == cleanAnswer(words[index].word)) {
      setState(() { solved = true; message = 'إجابة ممتازة!'; });
      final points = hintLevel == 0 ? 15 : 10;
      final first = await awardOnce('word_' + index.toString(), points, widget.onEarn);
      if (mounted) setState(() => message = first ? 'صحيح! ربحت ' + points.toString() + ' نقطة.' : 'صحيح! سبق احتساب نقاط هذه الكلمة.');
    } else { setState(() => message = 'ليست الكلمة المطلوبة. حاول من جديد.'); }
  }
  String get hintText {
    if (hintLevel == 1) return words[index].hint1;
    if (hintLevel == 2) return words[index].hint2;
    if (hintLevel == 3) return words[index].hint3;
    return 'اطلب تلميحاً إذا احتجت إلى مساعدة.';
  }
  void next() { setState(() { index = (index + 1) % words.length; hintLevel = 0; solved = false; message = ''; input.clear(); }); }
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('خمن الكلمة')),
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
    return Scaffold(
      appBar: AppBar(title: const Text('التحديات اليومية')),
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
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('عبارات جميلة')),
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
