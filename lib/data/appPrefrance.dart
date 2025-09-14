import 'package:shared_preferences/shared_preferences.dart';


class AppPreferences {
  static const String _keyLanguageCode = 'language_code';

  /// Save language code
  static Future<void> saveLanguageCode(String code) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyLanguageCode, code);
  }

  /// Get language code
  static Future<String?> getLanguageCode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyLanguageCode);
  }
  static const String _allowSaleKey = 'allow_sale_without_stock';
  static const String _keyThemeMode = 'theme_mode';


  // 🔹 Allow Sale Without Stock
  static Future<void> setAllowSaleWithoutStock(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_allowSaleKey, value);
  }

  static Future<bool> getAllowSaleWithoutStock() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_allowSaleKey) ?? false; // default = false
  }
    /// Save theme mode (light / dark / system)
  static Future<void> saveThemeMode(String mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyThemeMode, mode);
  }

  /// Get theme mode
  static Future<String?> getThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyThemeMode);
  }
}
