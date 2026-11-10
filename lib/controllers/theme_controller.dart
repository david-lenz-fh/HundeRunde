import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeController extends ChangeNotifier {
  static const _preferenceKey = 'isDarkTheme';

  ThemeController._(this._preferences, this._themeMode);

  final SharedPreferences _preferences;
  ThemeMode _themeMode;

  ThemeMode get themeMode => _themeMode;

  static Future<ThemeController> load(SharedPreferences preferences) async {
    final isDark = preferences.getBool(_preferenceKey) ?? false;
    return ThemeController._(
      preferences,
      isDark ? ThemeMode.dark : ThemeMode.light,
    );
  }

  Future<void> setThemeMode(ThemeMode themeMode) async {
    if (_themeMode == themeMode) return;

    _themeMode = themeMode;
    notifyListeners();
    await _preferences.setBool(_preferenceKey, themeMode == ThemeMode.dark);
  }
}
