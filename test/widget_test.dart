// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:pos/main.dart';

void main() {
  testWidgets('App starts with splash screen', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const PosApp());

    // Verify that splash screen is shown
    expect(find.text('POS UMKM'), findsOneWidget);
    expect(find.text('Point of Sale untuk UMKM'), findsOneWidget);
    
    // Wait for the timer to complete and navigation to happen
    await tester.pumpAndSettle(const Duration(seconds: 3));
  });
}
