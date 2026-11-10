import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:starter_flutter/controllers/theme_controller.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ThemeController', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('defaults to light theme when no preference is saved', () async {
      final preferences = await SharedPreferences.getInstance();
      final controller = await ThemeController.load(preferences);

      expect(controller.themeMode, ThemeMode.light);

      controller.dispose();
    });

    test('restores dark theme from saved preference', () async {
      SharedPreferences.setMockInitialValues({'isDarkTheme': true});
      final preferences = await SharedPreferences.getInstance();

      final controller = await ThemeController.load(preferences);

      expect(controller.themeMode, ThemeMode.dark);

      controller.dispose();
    });

    test('saves selected theme and notifies listeners', () async {
      final preferences = await SharedPreferences.getInstance();
      final controller = await ThemeController.load(preferences);
      var notifications = 0;
      controller.addListener(() => notifications++);

      await controller.setThemeMode(ThemeMode.dark);

      expect(controller.themeMode, ThemeMode.dark);
      expect(preferences.getBool('isDarkTheme'), isTrue);
      expect(notifications, 1);

      await controller.setThemeMode(ThemeMode.light);

      expect(controller.themeMode, ThemeMode.light);
      expect(preferences.getBool('isDarkTheme'), isFalse);
      expect(notifications, 2);

      controller.dispose();
    });
  });
}
