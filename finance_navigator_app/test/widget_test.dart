// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:finance_navigator/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('App starts with splash screen', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const FinanceNavigatorApp());

    // Verify that the splash screen shows the app name.
    expect(find.text('Finance Navigator'), findsOneWidget);
    expect(find.text('Your money, under control'), findsOneWidget);
  });
}
