import 'dart:math' as math;
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

List<_Quote> _buildQuoteLibrary() {
  const categories = <String>['تحفيز','نجاح','حكمة','أخلاق','أمل','علم','صداقة','عائلة','عمل','سعادة'];
  const topics = <String>['العمل','العلم','الصداقة','الحياة','الطموح','الوقت','المعرفة','الأخلاق','التجربة','المستقبل'];
  const qualities = <String>['الجميل','الصادق','الهادئ','المنظم','النافع','المتجدد','الواعي','البسيط','الشجاع','المتوازن'];
  const ideas = <String>['الخطوة الصغيرة تصنع فرقاً كبيراً','التعلم يفتح أبواباً جديدة','الصدق يبني ثقة تدوم','الصبر يساعد على رؤية الصورة كاملة','الاحترام يجعل الاختلاف أكثر جمالاً','الإنجاز يحتاج إلى عمل مستمر','التعاون يختصر الطريق','القراءة توسع أفق التفكير','النية الطيبة تمنح العمل معنى','الهدوء يساعد على اتخاذ قرار أفضل'];
  const endings = <String>['مع الصبر','كل يوم','بخطوات ثابتة','بروح متفائلة','بنية صادقة','بهدوء وحكمة','مع احترام الآخرين','بالتعلم والتجربة','دون استعجال','بإتقان واهتمام'];
  const openings = <String>['ابدأ من','في طريق','تأمل','عند','مع','في ميدان','في','داخل','في عالم','من جمال'];
  const bridges = <String>['وتذكر أن','ستجد أن','فلا تنس أن','اجعل يقينك أن','وتعلم أن','واعرف أن','وتأكد أن','واكتشف أن','وتذكر دائماً أن','واعلم أن'];
  final topicsList = <String>[for (final x in topics) for (final y in qualities) '$x $y'];
  final endingsList = <String>[for (final x in ideas) for (final y in endings) '$x $y'];
  return List<_Quote>.generate(100000, (i) {
    final c = i ~/ 10000;
    final n = i % 10000;
    final topic = topicsList[n ~/ 100];
    final ending = endingsList[n % 100];
    final opening = openings[c];
    final bridge = bridges[c];
    final text = switch (c) {
      0 => '$opening $topic، $bridge $ending.',
      1 => '$opening $topic، $ending.',
      2 => '$opening $topic؛ $bridge $ending.',
      3 => '$opening $topic، اجعل مبدأك أن $ending.',
      4 => '$opening $topic، تذكر دائماً أن $ending.',
      5 => '$opening $topic، $bridge $ending.',
      6 => '$opening $topic، فالصديق الطيب يعرف أن $ending.',
      7 => '$opening $topic، واجعل البيت مساحةً لـ$ending.',
      8 => '$opening $topic، فالعمل المتقن يعني أن $ending.',
      _ => '$opening $topic أن $ending.',
    };
    return _Quote(text, categories[c]);
  });
}

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
  int visibleCount = 50;
  late final List<_Quote> _quotes = _buildQuoteLibrary();

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
      visibleCount = 50;
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
    final allFiltered = _quotes.where((q) {
      if (selected == 'المفضلة') return favorites.contains(q.text);
      if (seenQuotes.contains(q.text)) return false;
      if (selected == 'الكل') return true;
      return q.category == selected;
    }).toList();
    final filtered = allFiltered.take(visibleCount).toList();

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
                Text('${allFiltered.length} عبارة متاحة', style: const TextStyle(color: Colors.white60, fontSize: 12)),
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
            if (filtered.length < allFiltered.length)
              Padding(
                padding: const EdgeInsets.only(top: 8, bottom: 14),
                child: OutlinedButton.icon(
                  onPressed: () => setState(() => visibleCount = (visibleCount + 50).clamp(0, allFiltered.length).toInt()),
                  icon: const Icon(Icons.expand_more_rounded),
                  label: Text('عرض 50 عبارة إضافية • المتبقي ${allFiltered.length - filtered.length}'),
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
