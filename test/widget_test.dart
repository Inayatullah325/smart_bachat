// Basic smoke test to verify that the app builds successfully.

import 'package:flutter_test/flutter_test.dart';
import 'package:smart_bachat/main.dart';

void main() {
  testWidgets('App smoke test - builds successfully', (
    WidgetTester tester,
  ) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify that the MyApp widget is present.
    expect(find.byType(MyApp), findsOneWidget);
  });
}
