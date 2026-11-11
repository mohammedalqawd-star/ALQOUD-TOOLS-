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

  void _changeCategory(String value) {
    setState(() {
      category = value;
      from = _units[value]!.keys.first;
      to = _units[value]!.keys.elementAt(1);
    });
  }

  @override
  void dispose() { input.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final options = _units[category]!.keys.toList();
    final result = _result;
    return Scaffold(
      backgroundColor: const Color(0xFF17243B),
      appBar: AppBar(backgroundColor: const Color(0xFF244A78), foregroundColor: const Color(0xFFD7E8FF), title: const Text('محول الوحدات')),
      body: ListView(padding: const EdgeInsets.all(18), children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF28649A), Color(0xFF243B66)]), borderRadius: BorderRadius.circular(23)),
          child: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Icon(Icons.swap_horiz_rounded, color: Color(0xFFB8DDFF), size: 38),
            SizedBox(height: 8),
            Text('حوّل وحداتك بسهولة', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
            Text('النتائج فورية وتعمل دون اتصال بالإنترنت.', style: TextStyle(color: Colors.white70)),
          ]),
        ),
        const SizedBox(height: 18),
        DropdownButtonFormField<String>(
          value: category,
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
          value: from,
          decoration: const InputDecoration(labelText: 'من وحدة'),
          items: options.map((v) => DropdownMenuItem(value: v, child: Text(v))).toList(),
          onChanged: (v) => setState(() => from = v ?? from),
        ),
        const SizedBox(height: 10),
        Center(child: IconButton.filledTonal(
          tooltip: 'تبديل الوحدتين',
          onPressed: () => setState(() { final old = from; from = to; to = old; }),
          icon: const Icon(Icons.swap_vert_rounded),
        )),
        DropdownButtonFormField<String>(
          value: to,
          decoration: const InputDecoration(labelText: 'إلى وحدة'),
          items: options.map((v) => DropdownMenuItem(value: v, child: Text(v))).toList(),
          onChanged: (v) => setState(() => to = v ?? to),
        ),
        const SizedBox(height: 18),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(color: const Color(0xFF203958), borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0xFF8BC8FF).withOpacity(.4))),
          child: Column(children: [
            const Text('النتيجة', style: TextStyle(color: Color(0xFFB8DDFF))),
            const SizedBox(height: 8),
            SelectableText(
              result == null || !result.isFinite ? 'أدخل قيمة صحيحة' : result.toStringAsPrecision(10).replaceFirst(RegExp(r'\\.?0+$'), ''),
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: Color(0xFFD7E8FF)),
            ),
            const SizedBox(height: 5),
            Text('$from  ←  $to', style: const TextStyle(color: Colors.white60)),
            const SizedBox(height: 10),
            OutlinedButton.icon(
              onPressed: result == null || !result.isFinite ? null : () => Clipboard.setData(ClipboardData(text: result.toString())),
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
  void initState() { super.initState(); _load(); }

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
    setState(() { notes.insert(0, value); controller.clear(); });
    await _save();
    FocusScope.of(context).unfocus();
  }

  Future<void> _delete(int index) async {
    setState(() => notes.removeAt(index));
    await _save();
  }

  @override
  void dispose() { controller.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: const Color(0xFF30213B),
    appBar: AppBar(backgroundColor: const Color(0xFF593D70), foregroundColor: const Color(0xFFF0D7FF), title: const Text('ملاحظاتي السريعة')),
    body: ListView(padding: const EdgeInsets.all(16), children: [
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: const Color(0xFF49345B), borderRadius: BorderRadius.circular(20)),
        child: Column(children: [
          TextField(
            controller: controller,
            minLines: 2,
            maxLines: 5,
            decoration: const InputDecoration(hintText: 'اكتب فكرة أو تذكيراً تريد الاحتفاظ به...', border: OutlineInputBorder()),
          ),
          const SizedBox(height: 10),
          SizedBox(width: double.infinity, child: FilledButton.icon(
            style: FilledButton.styleFrom(backgroundColor: const Color(0xFFD2A8F0), foregroundColor: const Color(0xFF30213B)),
            onPressed: _add,
            icon: const Icon(Icons.save_outlined),
            label: const Text('حفظ الملاحظة'),
          )),
        ]),
      ),
      const SizedBox(height: 18),
      Row(children: [
        const Expanded(child: Text('ملاحظاتك', style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold))),
        Text('${notes.length}', style: const TextStyle(color: Colors.white60)),
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
            trailing: Wrap(mainAxisSize: MainAxisSize.min, children: [
              IconButton(
                tooltip: 'نسخ',
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: e.value));
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم نسخ الملاحظة')));
                },
                icon: const Icon(Icons.copy_outlined),
              ),
              IconButton(tooltip: 'حذف', onPressed: () => _delete(e.key), icon: const Icon(Icons.delete_outline)),
            ]),
          ),
        )),
      const SizedBox(height: 10),
      const Text('ملاحظاتك محفوظة محلياً على الجهاز.', style: TextStyle(color: Colors.white54, fontSize: 11)),
    ]),
  );
}
