import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:starter_flutter/controllers/theme_controller.dart';
import 'package:starter_flutter/screens/settings_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  Future<ThemeController> createController() async {
    final preferences = await SharedPreferences.getInstance();
    return ThemeController.load(preferences);
  }

  Widget buildSettingsScreen(ThemeController controller) {
    return ChangeNotifierProvider<ThemeController>.value(
      value: controller,
      child: const MaterialApp(home: SettingsScreen()),
    );
  }

  testWidgets('shows theme choices and logout action', (tester) async {
    final controller = await createController();
    await tester.pumpWidget(buildSettingsScreen(controller));

    expect(find.text('Einstellungen'), findsOneWidget);
    expect(find.text('Light Theme'), findsOneWidget);
    expect(find.text('Dark Theme'), findsOneWidget);
    expect(find.text('Abmelden'), findsOneWidget);

    controller.dispose();
  });

  testWidgets('switches and persists the selected theme', (tester) async {
    final controller = await createController();
    final preferences = await SharedPreferences.getInstance();
    await tester.pumpWidget(buildSettingsScreen(controller));

    await tester.tap(find.text('Dark Theme'));
    await tester.pumpAndSettle();

    expect(controller.themeMode, ThemeMode.dark);
    expect(preferences.getBool('isDarkTheme'), isTrue);

    controller.dispose();
  });

  testWidgets('asks for confirmation before logging out', (tester) async {
    final controller = await createController();
    await tester.pumpWidget(buildSettingsScreen(controller));

    await tester.tap(find.text('Abmelden'));
    await tester.pumpAndSettle();

    expect(find.text('Möchtest du dich wirklich abmelden?'), findsOneWidget);
    expect(find.text('Abbrechen'), findsOneWidget);

    await tester.tap(find.text('Abbrechen'));
    await tester.pumpAndSettle();

    expect(find.text('Möchtest du dich wirklich abmelden?'), findsNothing);
    controller.dispose();
  });
}
