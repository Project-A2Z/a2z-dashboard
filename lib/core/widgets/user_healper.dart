import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class UserHelper {
  static Future<String> loadUserName() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      String? name = prefs.getString('userName');

      if ((name == null || name.isEmpty) && prefs.containsKey('user')) {
        final userJson = prefs.getString('user');
        if (userJson != null && userJson.isNotEmpty) {
          try {
            final Map<String, dynamic> userMap = jsonDecode(userJson);
            name = (userMap['firstName'] ?? userMap['name'] ?? '').toString();
          } catch (_) {
            name = null;
          }
        }
      }

      return name?.trim() ?? '';
    } catch (e) {
      return '';
    }
  }
}
