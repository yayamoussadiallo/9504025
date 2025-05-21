import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferenceService {
  static Future<void> setValue(String key, String value) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(key, value);
  }

  static Future<String> getValue(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return (prefs.getString(key) ?? "");
  }
}
