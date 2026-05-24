// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'package:auto_qui/main.dart';

void main() {
  testWidgets('AutoQui MVP smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const AutoQuiApp(showMap: false));

    expect(find.text('AutoQui'), findsOneWidget);
    expect(find.text('Localizza'), findsOneWidget);
    expect(find.text('Salva parcheggio'), findsOneWidget);
    expect(find.text("Vai all'auto"), findsNothing);
  });
}
