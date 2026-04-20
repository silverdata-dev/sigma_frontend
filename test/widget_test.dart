import 'package:flutter_test/flutter_test.dart';
import 'package:sigma_frontend/main.dart';

void main() {
  testWidgets('Health check display test', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('Backend Status:'), findsOneWidget);
    expect(find.text('Sigma Dashboard'), findsOneWidget);
  });
}
