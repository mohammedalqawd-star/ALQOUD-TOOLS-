import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

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

class HomePage extends StatelessWidget {
  const HomePage({super.key});
  @override
  Widget build(BuildContext context) {
    final tools = <(String, IconData, Widget)>[
      ('حاسبة الأرباح', Icons.trending_up, const ProfitPage()),
      ('حاسبة الخصومات', Icons.percent, const DiscountPage()),
      ('حاسبة الأقساط', Icons.calendar_month, const InstallmentPage()),
      ('الجملة والتجزئة', Icons.storefront, const WholesalePage()),
      ('الفواتير المحفوظة', Icons.receipt_long, const SavedPage()),
    ];
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: const Text('ALQOUD TOOLS')),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [green, Color(0xFF14543D)]),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: gold),
              ),
              child: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('أدواتك التجارية في مكان واحد', style: TextStyle(fontSize: 20, color: gold, fontWeight: FontWeight.bold)),
                SizedBox(height: 8),
                Text('حسابات سهلة، وبيانات محفوظة على هاتفك. تعمل الأدوات الأساسية دون إنترنت.'),
              ]),
            ),
            const SizedBox(height: 18),
            ...tools.map((t) => Card(
              color: const Color(0xFF102B22),
              child: ListTile(
                leading: Icon(t.$2, color: gold),
                title: Text(t.$1),
                trailing: const Icon(Icons.chevron_left),
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => t.$3)),
              ),
            )),
            const SizedBox(height: 12),
            const Text('الإعلانات قد تظهر عند تفعيل AdMob والاتصال بالإنترنت.'),
            const SizedBox(height: 8),
            const Text('ALQOUD TOOLS © 2026', textAlign: TextAlign.center, style: TextStyle(color: Colors.white54)),
          ],
        ),
      ),
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
