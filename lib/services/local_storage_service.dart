import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageService {
  static late SharedPreferences _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static Future<void> saveToken(String token) async {
    await _prefs.setString('token', token);
  }

  static Future<String?> getToken() async {
    return _prefs.getString('token');
  }

  static Future<void> clearToken() async {
    await _prefs.remove('token');
  }

  static Future<void> saveUserId(String userId) async {
    await _prefs.setString('userId', userId);
  }

  static Future<String?> getUserId() async {
    return _prefs.getString('userId');
  }

  static Future<void> clearUserId() async {
    await _prefs.remove('userId');
  }
}
