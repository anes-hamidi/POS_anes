import 'package:flutter/material.dart';
import 'package:myapp/data/appPrefrance.dart';

class ThemeProvider with ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;

  ThemeMode get themeMode => _themeMode;

  /// Load saved theme
  Future<void> loadTheme() async {
    final mode = await AppPreferences.getThemeMode();
    if (mode != null) {
      switch (mode) {
        case 'light':
          _themeMode = ThemeMode.light;
          break;
        case 'dark':
          _themeMode = ThemeMode.dark;
          break;
        default:
          _themeMode = ThemeMode.system;
      }
      notifyListeners();
    }
  }

  void toggleTheme() {
    if (_themeMode == ThemeMode.light) {
      _themeMode = ThemeMode.dark;
      AppPreferences.saveThemeMode('dark');
    } else {
      _themeMode = ThemeMode.light;
      AppPreferences.saveThemeMode('light');
    }
    notifyListeners();
  }

  void setSystemTheme() {
    _themeMode = ThemeMode.system;
    AppPreferences.saveThemeMode('system');
    notifyListeners();
  }
}
