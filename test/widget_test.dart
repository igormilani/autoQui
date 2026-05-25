// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:auto_qui/main.dart';

void main() {
  testWidgets('AutoQui MVP smoke test', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(const AutoQuiApp(showMap: false, showAds: false));
    await tester.pumpAndSettle();

    expect(find.text('AutoQui'), findsOneWidget);
    expect(find.text('Locate'), findsOneWidget);
    expect(find.text('Save parking'), findsOneWidget);
    expect(find.text('Go to car'), findsNothing);
  });
}
