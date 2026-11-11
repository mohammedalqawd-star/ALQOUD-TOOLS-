import 'package:flutter_test/flutter_test.dart';
import 'package:alqoud_tools/main.dart';

void main() {
  testWidgets('app opens with ALQOUD branding', (tester) async {
    await tester.pumpWidget(const AlQoudApp());
    expect(find.text('ALQOUD TOOLS'), findsOneWidget);
  });
}
