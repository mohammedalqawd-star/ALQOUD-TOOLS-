import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app_feedback.dart';

const _gold = Color(0xFFE2B8FF);
const _deep = Color(0xFF17152B);
const _green = Color(0xFF49316E);
const _panel = Color(0xFF29233F);

class _Quote {
  final String text;
  final String category;
  const _Quote(this.text, this.category);
}

const _quotes = <_Quote>[
  _Quote('ابدأ بما تستطيع، ومن حيث أنت، ولا تنتظر الظروف المثالية.', 'تحفيز'),
  _Quote('كل خطوة ثابتة، مهما كانت صغيرة، تقرّبك من هدفك.', 'تحفيز'),
  _Quote('اجعل أفعالك تتحدث عن طموحك.', 'تحفيز'),
  _Quote('لا تجعل تأخر الوصول سبباً للتوقف عن السير.', 'تحفيز'),
  _Quote('القوة أن تتعلم ثم تحاول من جديد.', 'تحفيز'),
  _Quote('الأيام تصنعها القرارات الصغيرة المتكررة.', 'تحفيز'),
  _Quote('ثق بقدرتك على التعلم، وامنح نفسك وقتاً كافياً.', 'تحفيز'),
  _Quote('النجاح نتيجة عمل منظم وصبر طويل.', 'نجاح'),
  _Quote('لا تقارن بدايتك بمنتصف طريق شخص آخر.', 'نجاح'),
  _Quote('الإنجاز الحقيقي أن تصبح أفضل من نفسك بالأمس.', 'نجاح'),
  _Quote('الفكرة الجيدة تحتاج إلى تنفيذ، لا إلى انتظار.', 'نجاح'),
  _Quote('رتّب أولوياتك، فالوقت رأس مال لا يعود.', 'نجاح'),
  _Quote('التعثر محطة للتعلم، وليس نهاية الطريق.', 'نجاح'),
  _Quote('من أتقن عمله ترك أثراً يسبق اسمه.', 'نجاح'),
  _Quote('الكلمة الطيبة تفتح أبواباً لا تفتحها القوة.', 'أخلاق'),
  _Quote('عامل الناس بما تحب أن يعاملوك به.', 'أخلاق'),
  _Quote('الاحترام يظهر في الحديث كما يظهر في الاختلاف.', 'أخلاق'),
  _Quote('التواضع لا ينقص قدرك، بل يزيده.', 'أخلاق'),
  _Quote('كن صادقاً؛ فالوضوح راحة للقلب والعقل.', 'أخلاق'),
  _Quote('الوفاء أن تحفظ الود حتى في غياب أصحابه.', 'أخلاق'),
  _Quote('أجمل المكاسب سمعة طيبة وأثر حسن.', 'أخلاق'),
  _Quote('العقل الهادئ يرى خيارات أكثر.', 'حكمة'),
  _Quote('ليس كل صمت ضعفاً، وليس كل كلام شجاعة.', 'حكمة'),
  _Quote('استمع لتفهم، لا لتنتظر دورك في الكلام.', 'حكمة'),
  _Quote('من عرف قدر وقته أحسن اختيار معاركه.', 'حكمة'),
  _Quote('الرأي يتغير عندما تظهر معرفة أفضل.', 'حكمة'),
  _Quote('الحكمة أن تعرف متى تبدأ ومتى تتوقف.', 'حكمة'),
  _Quote('لا تحكم على كتاب من صفحة واحدة.', 'حكمة'),
  _Quote('بعد العسر تتسع الطرق، فتمسّك بالأمل.', 'أمل'),
  _Quote('قد يحمل الغد فرصة لم تكن في الحسبان.', 'أمل'),
  _Quote('ابتسم للحياة، واصنع فيها سبباً جميلاً.', 'أمل'),
  _Quote('الأمل لا يلغي الصعوبات، لكنه يمنحك سبباً للمحاولة.', 'أمل'),
  _Quote('لا تفقد نورك بسبب يوم غائم.', 'أمل'),
  _Quote('كل صباح بداية جديدة لمن يريد أن يتعلم.', 'أمل'),
  _Quote('القلوب المطمئنة ترى النعمة في التفاصيل.', 'أمل'),
  _Quote('العلم يفتح آفاقاً، والفضول يحافظ على اتساعها.', 'علم'),
  _Quote('اسأل لتتعلم، وابحث لتتأكد، وجرّب لتفهم.', 'علم'),
  _Quote('المعرفة التي تطبقها تصبح مهارة.', 'علم'),
  _Quote('اقرأ قليلاً كل يوم، فالتراكم يصنع فرقاً.', 'علم'),
  _Quote('لا تخجل من السؤال؛ فالسؤال بداية الفهم.', 'علم'),
  _Quote('تعلم مهارة جديدة، فقد تصبح مفتاح فرصتك القادمة.', 'علم'),
];

class QuoteLibraryPage extends StatefulWidget {
  const QuoteLibraryPage({super.key});
  @override
  State<QuoteLibraryPage> createState() => _QuoteLibraryPageState();
}

class _QuoteLibraryPageState extends State<QuoteLibraryPage> {
  static const _categories = ['الكل', 'تحفيز', 'نجاح', 'حكمة', 'أخلاق', 'أمل', 'علم', 'المفضلة'];
  String selected = 'الكل';
  Set<String> favorites = <String>{};
  Set<String> seenQuotes = <String>{};
  int dailyIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    var seen = (prefs.getStringList('seen_quotes_v1') ?? <String>[]).toSet();
    if (seen.length >= _quotes.length) {
      seen.clear();
      await prefs.remove('seen_quotes_v1');
    }
    final unseen = _quotes.where((q) => !seen.contains(q.text)).toList();
    final now = DateTime.now();
    final dayIndex = (now.year * 366 + now.month * 31 + now.day) % unseen.length;
    if (!mounted) return;
    setState(() {
      favorites = (prefs.getStringList('favorite_quotes_v2') ?? []).toSet();
      seenQuotes = seen;
      dailyIndex = _quotes.indexOf(unseen[dayIndex]);
    });
  }

  Future<void> _markSeen(String quote) async {
    final next = Set<String>.from(seenQuotes)..add(quote);
    if (next.length >= _quotes.length) next.clear();
    final prefs = await SharedPreferences.getInstance();
    if (next.isEmpty) {
      await prefs.remove('seen_quotes_v1');
    } else {
      await prefs.setStringList('seen_quotes_v1', next.toList());
    }
    final unseen = _quotes.where((q) => !next.contains(q.text)).toList();
    if (!mounted) return;
    setState(() {
      seenQuotes = next;
      if (unseen.isNotEmpty) dailyIndex = _quotes.indexOf(unseen[math.Random().nextInt(unseen.length)]);
    });
  }

  Future<void> _toggleFavorite(String quote) async {
    final next = Set<String>.from(favorites);
    final adding = !next.contains(quote);
    if (adding) {
      next.add(quote);
    } else {
      next.remove(quote);
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('favorite_quotes_v2', next.toList());
    if (!mounted) return;
    setState(() => favorites = next);
    if (adding) await AppFeedback.play(SoundCue.correct);
  }

  Future<void> _copy(String quote) async {
    await Clipboard.setData(ClipboardData(text: quote));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('تم نسخ العبارة، يمكنك مشاركتها الآن')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _quotes.where((q) {
      if (selected == 'المفضلة') return favorites.contains(q.text);
      if (seenQuotes.contains(q.text)) return false;
      if (selected == 'الكل') return true;
      return q.category == selected;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF49316E),
        foregroundColor: const Color(0xFFE2B8FF),
        title: const Text('مكتبة العبارات'),
        actions: [
          IconButton(
            tooltip: 'نسخ عبارة اليوم',
            onPressed: () => _copy(_quotes[dailyIndex].text),
            icon: const Icon(Icons.copy_all_outlined),
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [_deep, Color(0xFF302347), _deep],
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
          ),
        ),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF60407E), Color(0xFF29233F), Color(0xFF3C315E)],
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                ),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: _gold.withOpacity(.8)),
                boxShadow: [BoxShadow(color: _gold.withOpacity(.10), blurRadius: 22, offset: const Offset(0, 8))],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.auto_awesome, color: _gold),
                      SizedBox(width: 8),
                      Text('عبارة اليوم', style: TextStyle(color: _gold, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '“${_quotes[dailyIndex].text}”',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 21, height: 1.8, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 14),
                  Wrap(
                    spacing: 8,
                    children: [
                      TextButton.icon(
                        onPressed: () => _copy(_quotes[dailyIndex].text),
                        icon: const Icon(Icons.copy, color: _gold, size: 18),
                        label: const Text('نسخ العبارة', style: TextStyle(color: _gold)),
                      ),
                      TextButton.icon(
                        onPressed: () => _markSeen(_quotes[dailyIndex].text),
                        icon: const Icon(Icons.check_circle_outline, color: _gold, size: 18),
                        label: const Text('تمت القراءة', style: TextStyle(color: _gold)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Text('اختر القسم', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            SizedBox(
              height: 44,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _categories.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final category = _categories[index];
                  final active = selected == category;
                  return ChoiceChip(
                    label: Text(category),
                    selected: active,
                    onSelected: (_) => setState(() => selected = category),
                    selectedColor: _gold,
                    backgroundColor: _panel,
                    labelStyle: TextStyle(
                      color: active ? _deep : Colors.white70,
                      fontWeight: FontWeight.bold,
                    ),
                    side: BorderSide(color: active ? _gold : Colors.white12),
                  );
                },
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Text(
                  selected == 'المفضلة' ? 'عباراتك المحفوظة' : 'اكتشف الكلمات',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                Text('${filtered.length} عبارة', style: const TextStyle(color: Colors.white60, fontSize: 12)),
              ],
            ),
            const SizedBox(height: 8),
            if (filtered.isEmpty)
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(color: _panel, borderRadius: BorderRadius.circular(18)),
                child: const Column(
                  children: [
                    Icon(Icons.bookmark_border, color: _gold, size: 38),
                    SizedBox(height: 8),
                    Text('لا توجد عبارات محفوظة بعد. اضغط علامة القلب على أي عبارة لإضافتها هنا.'),
                  ],
                ),
              ),
            ...filtered.map((quote) {
              final favorite = favorites.contains(quote.text);
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                decoration: BoxDecoration(
                  color: _panel,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: favorite ? _gold.withOpacity(.65) : Colors.white10),
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(14, 12, 16, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(color: _green, borderRadius: BorderRadius.circular(20)),
                            child: Text(quote.category, style: const TextStyle(color: _gold, fontSize: 11)),
                          ),
                          const Spacer(),
                          IconButton(
                            tooltip: favorite ? 'إزالة من المفضلة' : 'حفظ في المفضلة',
                            visualDensity: VisualDensity.compact,
                            onPressed: () => _toggleFavorite(quote.text),
                            icon: Icon(favorite ? Icons.favorite : Icons.favorite_border, color: favorite ? Colors.pinkAccent : Colors.white60),
                          ),
                          IconButton(
                            tooltip: 'تمت القراءة - إخفاء العبارة',
                            visualDensity: VisualDensity.compact,
                            onPressed: () => _markSeen(quote.text),
                            icon: const Icon(Icons.check_circle_outline, color: _gold),
                          ),
                          IconButton(
                            tooltip: 'نسخ',
                            visualDensity: VisualDensity.compact,
                            onPressed: () => _copy(quote.text),
                            icon: const Icon(Icons.copy_outlined, color: _gold),
                          ),
                        ],
                      ),
                      Text(quote.text, style: const TextStyle(fontSize: 16, height: 1.7)),
                    ],
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
