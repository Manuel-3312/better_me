import 'package:shared_preferences/shared_preferences.dart';

/// Service responsible for persisting user settings locally.
///
/// This class handles the storage and retrieval of application-level
/// preferences such as the selected locale and theme mode using
/// the shared_preferences plugin.
class PreferencesService {
  static const String _localeKey = 'selected_locale';
  static const String _themeKey = 'selected_theme';

  /// Saves the language code (e.g., 'en', 'es') to local storage.
  static Future<void> saveLocale(String languageCode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_localeKey, languageCode);
  }

  /// Retrieves the saved language code from local storage.
  static Future<String?> getLocale() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_localeKey);
  }

  /// Saves the theme mode to local storage as a string representation.
  static Future<void> saveTheme(String themeMode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeKey, themeMode);
  }

  /// Retrieves the saved theme mode string from local storage.
  static Future<String?> getTheme() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_themeKey);
  }
}