import 'package:flutter_test/flutter_test.dart';
import 'package:infertilityapp/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(MyApp(userId: 'test'));
    expect(find.text('Fertility Care'), findsOneWidget);
  });
}
