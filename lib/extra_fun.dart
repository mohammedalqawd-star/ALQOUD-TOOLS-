import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

const _funGold = Color(0xFFFFD477);

class FunLibraryPage extends StatelessWidget {
  const FunLibraryPage({super.key});
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        backgroundColor: const Color(0xFF17152B),
        appBar: AppBar(
          title: const Text('عالم المرح والثقافة'),
          backgroundColor: const Color(0xFF3A285B),
          foregroundColor: _funGold,
          bottom: const TabBar(isScrollable: true, tabs: [
            Tab(icon: Icon(Icons.emoji_events), text: 'مهام مسلية'),
            Tab(icon: Icon(Icons.format_quote), text: 'أمثال'),
            Tab(icon: Icon(Icons.sentiment_very_satisfied), text: 'الضحك'),
            Tab(icon: Icon(Icons.auto_stories), text: 'قصص عربية'),
          ]),
        ),
        body: const TabBarView(children: [
          _TasksTab(), _ProverbsTab(), _JokesTab(), _StoriesTab(),
        ]),
      ),
    );
  }
}

class _TasksTab extends StatefulWidget {
  const _TasksTab();
  @override
  State<_TasksTab> createState() => _TasksTabState();
}
class _TasksTabState extends State<_TasksTab> {
  int index = 0;
  final Set<int> done = {};
  static const List<Map<String, String>> tasks = [
    {'title':'تحدي الذاكرة','task':'انظر حولك 20 ثانية ثم اكتب خمسة أشياء رأيتها دون الرجوع إليها.','benefit':'تقوية الملاحظة والذاكرة.'},
    {'title':'مذيع الأخبار','task':'قدّم نشرة أخبار طريفة عن شيء عادي في غرفتك خلال 30 ثانية.','benefit':'التعبير والارتجال.'},
    {'title':'مخترع اليوم','task':'اختر غرضاً منزلياً واخترع له ثلاث استخدامات آمنة جديدة.','benefit':'الخيال والإبداع.'},
    {'title':'قصة بثلاث كلمات','task':'اكتب قصة قصيرة تستخدم الكلمات: قمر، مفتاح، رسالة.','benefit':'الكتابة والخيال.'},
    {'title':'صيد الحروف','task':'اذكر خمسة أشياء تبدأ بحرف تختاره خلال دقيقة.','benefit':'سرعة التفكير والمفردات.'},
    {'title':'تحدي الامتنان','task':'اكتب ثلاثة أشياء جيدة حدثت لك اليوم.','benefit':'التفكير الإيجابي.'},
    {'title':'رسام بالكلمات','task':'صف منظراً طبيعياً في أربعة أسطر دون ذكر اسمه.','benefit':'مهارة الوصف.'},
    {'title':'حساب سريع','task':'احسب ذهنياً 25 × 4 ثم 125 + 375.','benefit':'التركيز الحسابي.'},
    {'title':'حوار خيالي','task':'اكتب حواراً من أربعة أسطر بين كتاب وقلم.','benefit':'بناء الحوار.'},
    {'title':'كلمة جديدة','task':'تعلم كلمة جديدة واكتب معناها وجملة بها.','benefit':'زيادة المفردات.'},
    {'title':'رسالة لطيفة','task':'اكتب رسالة شكر قصيرة لشخص ساعدك.','benefit':'التقدير والاحترام.'},
    {'title':'محقق التفاصيل','task':'انظر إلى صورة ثم اذكر سبع تفاصيل بعد إغلاقها.','benefit':'قوة الملاحظة.'},
  ];
  @override
  Widget build(BuildContext context) {
    final task = tasks[index];
    return ListView(padding: const EdgeInsets.all(16), children: [
      Card(color: const Color(0xFF382B55), child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('مهمتك المختارة', style: TextStyle(color: _funGold)),
          const SizedBox(height: 12),
          Text(task['title']!, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Text(task['task']!, style: const TextStyle(fontSize: 17, height: 1.7)),
          const SizedBox(height: 10),
          Text('الفائدة: ' + task['benefit']!, style: const TextStyle(color: Colors.white70)),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: done.contains(index) ? null : () => setState(() => done.add(index)),
            icon: const Icon(Icons.check_circle),
            label: Text(done.contains(index) ? 'أنجزت المهمة' : 'أنهيت المهمة'),
          ),
        ]),
      )),
      const SizedBox(height: 12),
      Text('المهمة ' + (index + 1).toString() + ' من ' + tasks.length.toString() + ' • المنجزة ' + done.length.toString(), style: const TextStyle(color: _funGold)),
      LinearProgressIndicator(value: done.length / tasks.length, color: _funGold),
      OutlinedButton.icon(
        onPressed: () => setState(() => index = (index + 1) % tasks.length),
        icon: const Icon(Icons.shuffle), label: const Text('مهمة أخرى'),
      ),
    ]);
  }
}

class _ProverbsTab extends StatelessWidget {
  const _ProverbsTab();
  static const List<Map<String, String>> items = [
    {'text':'الصبر مفتاح الفرج','origin':'عربي شائع','meaning':'التأني والثبات يساعدان على تجاوز الشدائد.'},
    {'text':'من جدّ وجد ومن زرع حصد','origin':'عربي شائع','meaning':'النتائج الطيبة تأتي بعد العمل.'},
    {'text':'يد واحدة لا تصفق','origin':'عربي شائع','meaning':'التعاون يصنع قوة أكبر.'},
    {'text':'خير الكلام ما قل ودل','origin':'عربي شائع','meaning':'العبارة الواضحة الموجزة أبلغ.'},
    {'text':'القناعة كنز لا يفنى','origin':'عربي شائع','meaning':'الرضا يمنح راحة ويبعد الطمع.'},
    {'text':'في التأني السلامة وفي العجلة الندامة','origin':'عربي شائع','meaning':'فكر قبل أن تتصرف.'},
    {'text':'Actions speak louder than words','origin':'إنجليزي شائع','meaning':'الأفعال أصدق من الوعود.'},
    {'text':'A journey of a thousand miles begins with a single step','origin':'مثل متداول منسوب إلى حكمة صينية','meaning':'الإنجاز الكبير يبدأ بخطوة.'},
    {'text':'When in Rome, do as the Romans do','origin':'أوروبي شائع','meaning':'راعِ عادات المكان الذي تزوره.'},
    {'text':'The early bird catches the worm','origin':'إنجليزي شائع','meaning':'الاستعداد المبكر يمنح فرصة.'},
    {'text':'Better late than never','origin':'إنجليزي شائع','meaning':'البدء متأخراً أفضل من عدم البدء.'},
    {'text':'七転び八起き','origin':'ياباني شائع','meaning':'انهض بعد كل تعثر وحاول مجدداً.'},
    {'text':'千里之行，始于足下','origin':'صيني شائع','meaning':'الطريق الطويل يبدأ من موضعك.'},
  ];
  @override
  Widget build(BuildContext context) {
    return ListView(padding: const EdgeInsets.all(14), children: [
      const Text('أمثال عربية وعالمية مع شرحها', style: TextStyle(color: _funGold, fontSize: 21, fontWeight: FontWeight.bold)),
      ...items.map((item) => Card(color: const Color(0xFF292641), child: ListTile(
        title: Text(item['text']!),
        subtitle: Text(item['origin']! + '\nالمعنى: ' + item['meaning']!),
        isThreeLine: true,
        trailing: IconButton(icon: const Icon(Icons.copy, color: _funGold), onPressed: () {
          Clipboard.setData(ClipboardData(text: item['text']! + '\n' + item['meaning']!));
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم النسخ')));
        }),
      ))),
    ]);
  }
}

class _JokesTab extends StatefulWidget {
  const _JokesTab();
  @override
  State<_JokesTab> createState() => _JokesTabState();
}
class _JokesTabState extends State<_JokesTab> {
  int index = 0;
  bool revealed = false;
  static const List<Map<String, String>> jokes = [
    {'question':'المعلم: لماذا كتاب الرياضيات حزين؟','answer':'لأنه مليان مسائل وما لقى لها حل!'},
    {'question':'واحد اشترى ساعة ذكية','answer':'كلما سألها عن الوقت قالت: حدّثني أولاً!'},
    {'question':'طالب قال: ذاكرت من الفجر!','answer':'سألوه: أين وصلت؟ قال: وصلت لقرار أنام!'},
    {'question':'لماذا الكمبيوتر بارد؟','answer':'لأن عنده نوافذ مفتوحة!'},
    {'question':'هل عندكم كتاب عن الثقة بالنفس؟','answer':'نعم، خذه بنفسك من الرف!'},
    {'question':'الهاتف قال للشاحن','answer':'أنت تعطيني طاقة ولا تطلب كلمة مرور!'},
    {'question':'واحد نام مبكراً ليصحو نشيطاً','answer':'استيقظ وقرر تأجيل النشاط إلى الغد!'},
    {'question':'لماذا القلم لا يحب الزحام؟','answer':'لأنه يحب أن يكتب على راحته!'},
    {'question':'كيف ذاكرتك؟','answer':'ممتازة، بس نسيت أين وضعتها!'},
    {'question':'لماذا الكتاب متفائل؟','answer':'لأنه يعرف أن لكل صفحة بداية جديدة!'},
    {'question':'اشترى حذاء رياضياً','answer':'لبسه وجلس يشجعه حتى يمشي!'},
    {'question':'قال المنبه: قم!','answer':'رد: لا ترفع صوتك، أنا صاحي في أحلامي!'},
  ];
  @override
  Widget build(BuildContext context) {
    final joke = jokes[index];
    return ListView(padding: const EdgeInsets.all(16), children: [
      Card(color: const Color(0xFF633D45), child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(children: [
          const Icon(Icons.emoji_emotions, size: 52, color: _funGold),
          const Text('استراحة ضحك', style: TextStyle(fontSize: 23, color: _funGold, fontWeight: FontWeight.bold)),
          const SizedBox(height: 18),
          Text(joke['question']!, textAlign: TextAlign.center, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, height: 1.6)),
          if (revealed) Padding(padding: const EdgeInsets.all(14), child: Text(joke['answer']!, textAlign: TextAlign.center, style: const TextStyle(fontSize: 19, color: _funGold))),
          FilledButton(onPressed: () => setState(() => revealed = !revealed), child: Text(revealed ? 'إخفاء النهاية' : 'اكشف النكتة')),
          OutlinedButton(onPressed: () => setState(() { index = (index + 1) % jokes.length; revealed = false; }), child: const Text('نكتة أخرى')),
        ]),
      )),
      Text('النكتة ' + (index + 1).toString() + ' من ' + jokes.length.toString(), textAlign: TextAlign.center, style: const TextStyle(color: Colors.white54)),
    ]);
  }
}

class _StoriesTab extends StatefulWidget {
  const _StoriesTab();
  @override
  State<_StoriesTab> createState() => _StoriesTabState();
}
class _StoriesTabState extends State<_StoriesTab> {
  final Set<int> expanded = {};
  static const List<Map<String, String>> stories = [
    {'title':'العصفور والبذرة','body':'وجد عصفور بذرة صغيرة، فغرسها في تربة رطبة وظل يعتني بها. كبرت وصارت شجرة يستظل بها وأصدقاؤه.','lesson':'العمل الصغير المستمر يصنع أثراً كبيراً.'},
    {'title':'مصباح القرية','body':'وضع فتى مصباحاً أمام بيته في طريق مظلم. تبعه جاره ثم بقية أهل القرية، فأضاء الطريق كله.','lesson':'المبادرة الطيبة تشجع الآخرين.'},
    {'title':'التاجر والميزان','body':'لاحظ تاجر خللاً في ميزانه فأصلحه وأخبر زبائنه. كسب ثقتهم لأنهم وجدوا عنده الأمانة.','lesson':'الصدق أساس الثقة.'},
    {'title':'النملة والمطر','body':'وجدت نملة قطرة مطر تعترض طريقها، فبحثت عن مسار آمن ثم أرشدت صديقاتها إليه.','lesson':'التفكير والتعاون يحلان المشكلات.'},
    {'title':'الكتاب القديم','body':'وجدت طفلة كتاباً قديماً وبدأت تقرأه، فاكتشفت عالماً من الأفكار وصارت تخصص وقتاً للقراءة.','lesson':'قيمة الشيء فيما يقدمه لا في مظهره.'},
    {'title':'الراعي والنجمة','body':'تعلم راعٍ أسماء النجوم ودوّن مواقعها، حتى صار يرشد المسافرين في الليل.','lesson':'الملاحظة والتدوين يثبتان المعرفة.'},
    {'title':'النهر والحجر','body':'ظن حجر صغير أنه لا يؤثر في النهر، لكنه ساعد مع الزمن على تغيير مجرى الماء حوله.','lesson':'لا تستهن بالأثر الصغير.'},
    {'title':'النافذة الخضراء','body':'زرعت امرأة نبتة قرب نافذتها واعتنت بها كل يوم، حتى أصبحت زاوية البيت أجمل مكان فيه.','lesson':'العناية اليومية تصنع الجمال.'},
  ];
  @override
  Widget build(BuildContext context) {
    return ListView(padding: const EdgeInsets.all(14), children: [
      const Text('قصص عربية قصيرة أصلية', style: TextStyle(color: _funGold, fontSize: 21, fontWeight: FontWeight.bold)),
      const Text('افتح القصة واقرأ الفكرة التي نتعلمها منها.', style: TextStyle(color: Colors.white60)),
      ...List.generate(stories.length, (i) {
        final story = stories[i];
        final isOpen = expanded.contains(i);
        return Card(color: const Color(0xFF292641), child: Column(children: [
          ListTile(
            title: Text(story['title']!),
            subtitle: Text(isOpen ? 'اضغط للإغلاق' : 'اضغط لقراءة القصة'),
            trailing: Icon(isOpen ? Icons.expand_less : Icons.expand_more),
            onTap: () => setState(() { if (isOpen) { expanded.remove(i); } else { expanded.add(i); } }),
          ),
          if (isOpen) Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(story['body']!, style: const TextStyle(height: 1.8)),
              const SizedBox(height: 8),
              Text('العبرة: ' + story['lesson']!, style: const TextStyle(color: _funGold, fontWeight: FontWeight.bold, height: 1.6)),
              Align(alignment: Alignment.centerLeft, child: IconButton(icon: const Icon(Icons.copy, color: _funGold), onPressed: () {
                Clipboard.setData(ClipboardData(text: story['title']! + '\n' + story['body']! + '\n' + story['lesson']!));
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم نسخ القصة')));
              })),
            ]),
          ),
        ]));
      }),
    ]);
  }
}