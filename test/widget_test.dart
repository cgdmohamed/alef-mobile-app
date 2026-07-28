import 'package:flutter_test/flutter_test.dart';

import 'package:alef_mobile_app/main.dart';

void main() {
  testWidgets('App boots to the splash screen', (WidgetTester tester) async {
    await tester.pumpWidget(const AlefApp());
    await tester.pump();

    expect(find.text('منصة ألف'), findsOneWidget);

    // Let the splash screen's auto-navigation timer fire so it doesn't
    // leak past the test's tear-down.
    await tester.pump(const Duration(milliseconds: 1700));
  });
}
