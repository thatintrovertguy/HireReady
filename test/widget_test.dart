import 'package:flutter_test/flutter_test.dart';
import 'package:hirereadyy/main.dart';

void main() {
  testWidgets('HireReady app smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const HireReadyApp());

    // Verify HireReady title exists
    expect(find.text('HireReady'), findsOneWidget);
  });
}
