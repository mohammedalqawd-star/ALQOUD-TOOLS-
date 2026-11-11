import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ExpenseBookPage extends StatefulWidget {
  const ExpenseBookPage({super.key});
  @override
  State<ExpenseBookPage> createState() => _ExpenseBookPageState();
}

class _ExpenseBookPageState extends State<ExpenseBookPage> {
  static const _accent = Color(0xFF62D6B0);
  static const _bg = Color(0xFF102A2B);
  List<Map<String, dynamic>> entries = [];
  bool loading = true;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList('alqoud_ledger') ?? [];
    final parsed = <Map<String, dynamic>>[];
    for (final item in raw) {
      try { parsed.add(Map<String, dynamic>.from(jsonDecode(item) as Map)); } catch (_) {}
    }
    if (!mounted) return;
    setState(() { entries = parsed; loading = false; });
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('alqoud_ledger', entries.map((e) => jsonEncode(e)).toList());
  }

  double get _income => entries.where((e) => e['type'] == 'income')
      .fold(0.0, (sum, e) => sum + ((e['amount'] as num?)?.toDouble() ?? 0));
  double get _expense => entries.where((e) => e['type'] == 'expense')
      .fold(0.0, (sum, e) => sum + ((e['amount'] as num?)?.toDouble() ?? 0));
  String _money(double value) => value.toStringAsFixed(2);

  Future<void> _addEntry() async {
    final title = TextEditingController();
    final amount = TextEditingController();
    String type = 'expense';
    String category = 'عام';
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, refresh) => AlertDialog(
          backgroundColor: const Color(0xFF183D3C),
          title: const Text('إضافة حركة مالية'),
          content: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
            TextField(controller: title, autofocus: true, decoration: const InputDecoration(labelText: 'البيان أو الوصف')),
            const SizedBox(height: 12),
            TextField(controller: amount, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: const InputDecoration(labelText: 'المبلغ')),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: type,
              decoration: const InputDecoration(labelText: 'نوع الحركة'),
              items: const [
                DropdownMenuItem(value: 'expense', child: Text('مصروف')),
                DropdownMenuItem(value: 'income', child: Text('إيراد')),
              ],
              onChanged: (v) => refresh(() => type = v ?? 'expense'),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: category,
              decoration: const InputDecoration(labelText: 'التصنيف'),
              items: const ['عام', 'مبيعات', 'مشتريات', 'مواصلات', 'طعام', 'فواتير', 'أخرى']
                  .map((v) => DropdownMenuItem(value: v, child: Text(v))).toList(),
              onChanged: (v) => refresh(() => category = v ?? 'عام'),
            ),
          ])),
          actions: [
            TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('إلغاء')),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: _accent, foregroundColor: const Color(0xFF102A2B)),
              onPressed: () {
                final value = double.tryParse(amount.text.trim());
                if (title.text.trim().isEmpty || value == null || value <= 0) return;
                Navigator.pop(dialogContext, {
                  'title': title.text.trim(), 'amount': value, 'type': type,
                  'category': category, 'date': DateTime.now().toIso8601String(),
                });
              },
              child: const Text('حفظ'),
            ),
          ],
        ),
      ),
    );
    title.dispose();
    amount.dispose();
    if (result == null) return;
    setState(() => entries.insert(0, result));
    await _save();
  }

  Future<void> _delete(int index) async {
    final removed = entries.removeAt(index);
    setState(() {});
    await _save();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: const Text('تم حذف الحركة'),
      action: SnackBarAction(label: 'تراجع', onPressed: () async {
        setState(() => entries.insert(index.clamp(0, entries.length).toInt(), removed));
        await _save();
      }),
    ));
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: _bg,
    appBar: AppBar(
      backgroundColor: const Color(0xFF174B48),
      foregroundColor: const Color(0xFFB8F4DF),
      title: const Text('دفتر المصروفات والإيرادات'),
      actions: [IconButton(
        tooltip: 'معلومات',
        onPressed: () => showAboutDialog(
          context: context,
          applicationName: 'دفتر القعود',
          children: const [Text('سجل محلي بسيط يعمل دون إنترنت. أدخل الحركات بنفسك وراجع إجمالي الإيرادات والمصروفات.')],
        ),
        icon: const Icon(Icons.info_outline),
      )],
    ),
    floatingActionButton: FloatingActionButton.extended(
      backgroundColor: _accent,
      foregroundColor: const Color(0xFF102A2B),
      onPressed: _addEntry,
      icon: const Icon(Icons.add),
      label: const Text('حركة جديدة'),
    ),
    body: loading ? const Center(child: CircularProgressIndicator()) : ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
      children: [
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [Color(0xFF17645A), Color(0xFF123A40)]),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: _accent.withOpacity(.45)),
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('ملخصك المالي', style: TextStyle(color: Colors.white70)),
            const SizedBox(height: 7),
            Text('الرصيد الصافي: ${_money(_income - _expense)}', style: const TextStyle(fontSize: 25, fontWeight: FontWeight.w900)),
            const SizedBox(height: 16),
            Row(children: [
              Expanded(child: _LedgerTotal(label: 'الإيرادات', amount: _money(_income), color: _accent, icon: Icons.south_west)),
              const SizedBox(width: 10),
              Expanded(child: _LedgerTotal(label: 'المصروفات', amount: _money(_expense), color: const Color(0xFFFFA6A6), icon: Icons.north_east)),
            ]),
          ]),
        ),
        const SizedBox(height: 20),
        Row(children: [
          const Expanded(child: Text('سجل الحركات', style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold))),
          Text('${entries.length} حركة', style: const TextStyle(color: Colors.white60)),
        ]),
        const SizedBox(height: 8),
        if (entries.isEmpty)
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(color: Colors.white.withOpacity(.045), borderRadius: BorderRadius.circular(20)),
            child: const Column(children: [
              Icon(Icons.account_balance_wallet_outlined, size: 48, color: _accent),
              SizedBox(height: 10),
              Text('دفترك جاهز للبدء', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
              SizedBox(height: 5),
              Text('أضف أول إيراد أو مصروف، وستظهر ملخصاتك هنا.', textAlign: TextAlign.center, style: TextStyle(color: Colors.white60)),
            ]),
          )
        else
          ...entries.asMap().entries.map((entry) {
            final item = entry.value;
            final isIncome = item['type'] == 'income';
            final amount = (item['amount'] as num?)?.toDouble() ?? 0;
            final date = DateTime.tryParse(item['date']?.toString() ?? '');
            final dateLabel = date == null ? '' : '${date.year}/${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')}';
            return Card(
              color: const Color(0xFF193A3A),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: (isIncome ? _accent : const Color(0xFFFFA6A6)).withOpacity(.15),
                  child: Icon(isIncome ? Icons.add_rounded : Icons.remove_rounded, color: isIncome ? _accent : const Color(0xFFFFA6A6)),
                ),
                title: Text(item['title']?.toString() ?? 'حركة مالية', style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text('${item['category'] ?? 'عام'} • $dateLabel', style: const TextStyle(color: Colors.white60, fontSize: 12)),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('${isIncome ? '+' : '−'}${_money(amount)}', style: TextStyle(color: isIncome ? _accent : const Color(0xFFFFA6A6), fontWeight: FontWeight.bold)),
                    SizedBox(height: 25, child: IconButton(
                      padding: EdgeInsets.zero,
                      visualDensity: VisualDensity.compact,
                      onPressed: () => _delete(entry.key),
                      icon: const Icon(Icons.delete_outline, size: 18, color: Colors.white54),
                    )),
                  ],
                ),
              ),
            );
          }),
        const SizedBox(height: 8),
        const Text('ملاحظة: البيانات محفوظة على هذا الجهاز فقط. لا تُرسل إلى أي خادم.', style: TextStyle(color: Colors.white54, fontSize: 11)),
      ],
    ),
  );
}

class _LedgerTotal extends StatelessWidget {
  final String label;
  final String amount;
  final Color color;
  final IconData icon;
  const _LedgerTotal({required this.label, required this.amount, required this.color, required this.icon});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(color: Colors.black.withOpacity(.15), borderRadius: BorderRadius.circular(16)),
    child: Row(children: [
      Icon(icon, color: color, size: 19),
      const SizedBox(width: 7),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 11)),
        Text(amount, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: color, fontWeight: FontWeight.w900, fontSize: 16)),
      ])),
    ]),
  );
}


class UnitConverterPage extends StatefulWidget {
  const UnitConverterPage({super.key});
  @override
  State<UnitConverterPage> createState() => _UnitConverterPageState();
}

class _UnitConverterPageState extends State<UnitConverterPage> {
  static const Map<String, Map<String, double>> _units = {
    'الطول': {'متر': 1, 'كيلومتر': 1000, 'سنتيمتر': .01, 'مليمتر': .001, 'ميل': 1609.344, 'قدم': .3048, 'بوصة': .0254},
    'الوزن': {'كيلوجرام': 1, 'جرام': .001, 'طن': 1000, 'رطل': .45359237, 'أونصة': .0283495},
    'السعة': {'لتر': 1, 'مليلتر': .001, 'متر مكعب': 1000, 'جالون أمريكي': 3.7854118},
    'الزمن': {'ثانية': 1, 'دقيقة': 60, 'ساعة': 3600, 'يوم': 86400},
  };
  String category = 'الطول';
  String from = 'متر';
  String to = 'كيلومتر';
  final input = TextEditingController(text: '1');

  double? get _result {
    final value = double.tryParse(input.text.trim());
    if (value == null) return null;
    final units = _units[category]!;
    return value * units[from]! / units[to]!;
  }

  String _formatResult(double value) {
    var output = value.toStringAsFixed(6);
    if (output.contains('.')) {
      while (output.endsWith('0')) {
        output = output.substring(0, output.length - 1);
      }
      if (output.endsWith('.')) output = output.substring(0, output.length - 1);
    }
    return output;
  }

  void _changeCategory(String value) {
    setState(() {
      category = value;
      from = _units[value]!.keys.first;
      to = _units[value]!.keys.elementAt(1);
    });
  }

  @override
  void dispose() {
    input.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final options = _units[category]!.keys.toList();
    final result = _result;
    return Scaffold(
      backgroundColor: const Color(0xFF17243B),
      appBar: AppBar(
        backgroundColor: const Color(0xFF244A78),
        foregroundColor: const Color(0xFFD7E8FF),
        title: const Text('محول الوحدات'),
      ),
      body: ListView(padding: const EdgeInsets.all(18), children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [Color(0xFF28649A), Color(0xFF243B66)]),
            borderRadius: BorderRadius.circular(23),
          ),
          child: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Icon(Icons.swap_horiz_rounded, color: Color(0xFFB8DDFF), size: 38),
            SizedBox(height: 8),
            Text('حوّل وحداتك بسهولة', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
            Text('النتائج فورية وتعمل دون اتصال بالإنترنت.', style: TextStyle(color: Colors.white70)),
          ]),
        ),
        const SizedBox(height: 18),
        DropdownButtonFormField<String>(
          key: ValueKey('category_$category'),
          initialValue: category,
          decoration: const InputDecoration(labelText: 'نوع التحويل'),
          items: _units.keys.map((v) => DropdownMenuItem(value: v, child: Text(v))).toList(),
          onChanged: (v) => _changeCategory(v ?? category),
        ),
        const SizedBox(height: 14),
        TextField(
          controller: input,
          keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
          onChanged: (_) => setState(() {}),
          decoration: const InputDecoration(labelText: 'القيمة المراد تحويلها', prefixIcon: Icon(Icons.edit_outlined)),
        ),
        const SizedBox(height: 14),
        DropdownButtonFormField<String>(
          key: ValueKey('from_$category'),
          initialValue: from,
          decoration: const InputDecoration(labelText: 'من وحدة'),
          items: options.map((v) => DropdownMenuItem(value: v, child: Text(v))).toList(),
          onChanged: (v) => setState(() => from = v ?? from),
        ),
        const SizedBox(height: 10),
        Center(child: IconButton.filledTonal(
          tooltip: 'تبديل الوحدتين',
          onPressed: () => setState(() {
            final old = from;
            from = to;
            to = old;
          }),
          icon: const Icon(Icons.swap_vert_rounded),
        )),
        DropdownButtonFormField<String>(
          key: ValueKey('to_$category'),
          initialValue: to,
          decoration: const InputDecoration(labelText: 'إلى وحدة'),
          items: options.map((v) => DropdownMenuItem(value: v, child: Text(v))).toList(),
          onChanged: (v) => setState(() => to = v ?? to),
        ),
        const SizedBox(height: 18),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFF203958),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFF8BC8FF).withOpacity(.4)),
          ),
          child: Column(children: [
            const Text('النتيجة', style: TextStyle(color: Color(0xFFB8DDFF))),
            const SizedBox(height: 8),
            SelectableText(
              result == null || !result.isFinite ? 'أدخل قيمة صحيحة' : _formatResult(result),
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: Color(0xFFD7E8FF)),
            ),
            const SizedBox(height: 5),
            Text(from + '  ←  ' + to, style: const TextStyle(color: Colors.white60)),
            const SizedBox(height: 10),
            OutlinedButton.icon(
              onPressed: result == null || !result.isFinite ? null : () => Clipboard.setData(ClipboardData(text: _formatResult(result))),
              icon: const Icon(Icons.copy),
              label: const Text('نسخ النتيجة'),
            ),
          ]),
        ),
      ]),
    );
  }
}

class QuickNotesPage extends StatefulWidget {
  const QuickNotesPage({super.key});
  @override
  State<QuickNotesPage> createState() => _QuickNotesPageState();
}

class _QuickNotesPageState extends State<QuickNotesPage> {
  static const _key = 'alqoud_quick_notes';
  List<String> notes = [];
  final controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) setState(() => notes = prefs.getStringList(_key) ?? []);
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_key, notes);
  }

  Future<void> _add() async {
    final value = controller.text.trim();
    if (value.isEmpty) return;
    setState(() {
      notes.insert(0, value);
      controller.clear();
    });
    FocusScope.of(context).unfocus();
    await _save();
  }

  Future<void> _delete(int index) async {
    setState(() => notes.removeAt(index));
    await _save();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: const Color(0xFF30213B),
    appBar: AppBar(
      backgroundColor: const Color(0xFF593D70),
      foregroundColor: const Color(0xFFF0D7FF),
      title: const Text('ملاحظاتي السريعة'),
    ),
    body: ListView(padding: const EdgeInsets.all(16), children: [
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: const Color(0xFF49345B), borderRadius: BorderRadius.circular(20)),
        child: Column(children: [
          TextField(
            controller: controller,
            minLines: 2,
            maxLines: 5,
            decoration: const InputDecoration(
              hintText: 'اكتب فكرة أو تذكيراً تريد الاحتفاظ به...',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(width: double.infinity, child: FilledButton.icon(
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFD2A8F0),
              foregroundColor: const Color(0xFF30213B),
            ),
            onPressed: _add,
            icon: const Icon(Icons.save_outlined),
            label: const Text('حفظ الملاحظة'),
          )),
        ]),
      ),
      const SizedBox(height: 18),
      Row(children: [
        const Expanded(child: Text('ملاحظاتك', style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold))),
        Text(notes.length.toString(), style: const TextStyle(color: Colors.white60)),
      ]),
      const SizedBox(height: 8),
      if (notes.isEmpty)
        const Padding(
          padding: EdgeInsets.all(25),
          child: Column(children: [
            Icon(Icons.sticky_note_2_outlined, size: 48, color: Color(0xFFD2A8F0)),
            SizedBox(height: 8),
            Text('لا توجد ملاحظات بعد', style: TextStyle(color: Colors.white70)),
          ]),
        )
      else
        ...notes.asMap().entries.map((e) => Card(
          color: const Color(0xFF49345B),
          child: ListTile(
            title: Text(e.value, maxLines: 5, overflow: TextOverflow.ellipsis),
            leading: const Icon(Icons.notes_rounded, color: Color(0xFFD2A8F0)),
            trailing: Wrap(alignment: WrapAlignment.end, children: [
              IconButton(
                tooltip: 'نسخ',
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: e.value));
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم نسخ الملاحظة')));
                },
                icon: const Icon(Icons.copy_outlined),
              ),
              IconButton(
                tooltip: 'حذف',
                onPressed: () => _delete(e.key),
                icon: const Icon(Icons.delete_outline),
              ),
            ]),
          ),
        )),
      const SizedBox(height: 10),
      const Text('ملاحظاتك محفوظة محلياً على الجهاز.', style: TextStyle(color: Colors.white54, fontSize: 11)),
    ]),
  );
}

class AchievementsPage extends StatefulWidget {
  const AchievementsPage({super.key});
  @override
  State<AchievementsPage> createState() => _AchievementsPageState();
}

class _AchievementsPageState extends State<AchievementsPage> {
  int points = 0;
  int solvedActivities = 0;
  int completedDays = 0;
  int streak = 0;
  bool loading = true;

  String _dateKey(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return date.year.toString() + '-' + month + '-' + day;
  }

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final events = prefs.getStringList('earned_events') ?? [];
    final keys = prefs.getKeys();
    final days = keys.where((key) => key.startsWith('daily_done_') && prefs.getBool(key) == true).length;
    var cursor = DateTime.now();
    if (!(prefs.getBool('daily_done_' + _dateKey(cursor)) ?? false)) {
      cursor = cursor.subtract(const Duration(days: 1));
    }
    var currentStreak = 0;
    while (currentStreak < 3650 && (prefs.getBool('daily_done_' + _dateKey(cursor)) ?? false)) {
      currentStreak++;
      cursor = cursor.subtract(const Duration(days: 1));
    }
    if (!mounted) return;
    setState(() {
      points = prefs.getInt('game_points') ?? 0;
      solvedActivities = events.length;
      completedDays = days;
      streak = currentStreak;
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final badges = <_AchievementBadge>[
      _AchievementBadge('أول خطوة', 'اجمع 10 نقاط', Icons.flag_rounded, points >= 10),
      _AchievementBadge('متعلّم نشيط', 'اجمع 100 نقطة', Icons.menu_book_rounded, points >= 100),
      _AchievementBadge('مبدع', 'اجمع 300 نقطة', Icons.lightbulb_rounded, points >= 300),
      _AchievementBadge('أسطورة', 'اجمع 700 نقطة', Icons.workspace_premium_rounded, points >= 700),
      _AchievementBadge('جامع الإنجازات', 'أكمل 10 أنشطة', Icons.stars_rounded, solvedActivities >= 10),
      _AchievementBadge('مستمر', 'أكمل 3 تحديات يومية', Icons.calendar_month_rounded, completedDays >= 3),
      _AchievementBadge('أسبوع من التحدي', 'حافظ على سلسلة 7 أيام', Icons.local_fire_department_rounded, streak >= 7),
      _AchievementBadge('ألف نقطة', 'اجمع 1000 نقطة', Icons.military_tech_rounded, points >= 1000),
    ];
    final unlocked = badges.where((b) => b.unlocked).length;
    return Scaffold(
      backgroundColor: const Color(0xFF202A3B),
      appBar: AppBar(
        backgroundColor: const Color(0xFF354A70),
        foregroundColor: const Color(0xFFD5E3FF),
        title: const Text('إنجازاتي وشاراتي'),
        actions: [IconButton(tooltip: 'تحديث', onPressed: _load, icon: const Icon(Icons.refresh))],
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(padding: const EdgeInsets.all(16), children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [Color(0xFF3B5C91), Color(0xFF252F50)]),
                  borderRadius: BorderRadius.circular(23),
                  border: Border.all(color: const Color(0xFFB9D0FF).withOpacity(.35)),
                ),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text('رحلتك حتى الآن', style: TextStyle(color: Colors.white70)),
                  const SizedBox(height: 8),
                  Text(unlocked.toString() + ' / ' + badges.length.toString() + ' شارات مفتوحة', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900)),
                  const SizedBox(height: 14),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: LinearProgressIndicator(
                      value: unlocked / badges.length,
                      minHeight: 9,
                      color: const Color(0xFFD5E3FF),
                      backgroundColor: Colors.black.withOpacity(.2),
                    ),
                  ),
                ]),
              ),
              const SizedBox(height: 14),
              GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                childAspectRatio: 1.35,
                children: [
                  _AchievementStat(label: 'النقاط', value: points.toString(), icon: Icons.stars_rounded, color: const Color(0xFFFFD66E)),
                  _AchievementStat(label: 'الأنشطة المكتملة', value: solvedActivities.toString(), icon: Icons.task_alt_rounded, color: const Color(0xFF8DE2C1)),
                  _AchievementStat(label: 'أيام التحدي', value: completedDays.toString(), icon: Icons.event_available_rounded, color: const Color(0xFFFFA6C2)),
                  _AchievementStat(label: 'السلسلة الحالية', value: streak.toString() + ' يوم', icon: Icons.local_fire_department_rounded, color: const Color(0xFFFFB36D)),
                ],
              ),
              const SizedBox(height: 20),
              const Text('مجموعة الشارات', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
              const SizedBox(height: 10),
              ...badges.map((badge) => Card(
                color: badge.unlocked ? const Color(0xFF344A65) : const Color(0xFF293244),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: badge.unlocked ? const Color(0xFF5277A8) : Colors.white10,
                    child: Icon(badge.icon, color: badge.unlocked ? const Color(0xFFD5E3FF) : Colors.white38),
                  ),
                  title: Text(badge.title, style: TextStyle(fontWeight: FontWeight.bold, color: badge.unlocked ? Colors.white : Colors.white60)),
                  subtitle: Text(badge.description),
                  trailing: Icon(badge.unlocked ? Icons.verified_rounded : Icons.lock_outline_rounded, color: badge.unlocked ? const Color(0xFF8DE2C1) : Colors.white30),
                ),
              )),
              const SizedBox(height: 8),
              const Text('تُحسب الشارات من إنجازاتك المحفوظة على هذا الجهاز.', style: TextStyle(color: Colors.white54, fontSize: 11)),
            ]),
    );
  }
}

class _AchievementBadge {
  final String title;
  final String description;
  final IconData icon;
  final bool unlocked;
  const _AchievementBadge(this.title, this.description, this.icon, this.unlocked);
}

class _AchievementStat extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  const _AchievementStat({required this.label, required this.value, required this.icon, required this.color});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(13),
    decoration: BoxDecoration(
      color: const Color(0xFF303E56),
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: color.withOpacity(.2)),
    ),
    child: Row(children: [
      Icon(icon, color: color, size: 24),
      const SizedBox(width: 9),
      Expanded(child: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: const TextStyle(color: Colors.white60, fontSize: 11)),
        const SizedBox(height: 4),
        Text(value, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: color, fontWeight: FontWeight.w900, fontSize: 18)),
      ])),
    ]),
  );
}
