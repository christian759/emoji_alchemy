// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:emoji_alchemy/main.dart';

void main() {
  testWidgets('Home screen title appears', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(EmojiAlchemyApp(prefs: prefs));
    await tester.pumpAndSettle();

    expect(find.text('Emoji'), findsOneWidget);
    expect(find.text('Alchemy'), findsOneWidget);
    expect(find.text('Home'), findsWidgets);
  });
}
