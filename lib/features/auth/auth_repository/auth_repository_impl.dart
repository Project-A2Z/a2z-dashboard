import 'package:disctop_app/core/api_service.dart';
import 'package:disctop_app/features/auth/auth_repository/auth_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';

class AuthRepositoryImpl implements AuthRepository {
  final ApiService api;
  AuthRepositoryImpl(this.api);

  @override
  Future<Map<String, String>> login(String email, String password) async {
    try {
      final response = await api.login(email, password);

      final root = Map<String, dynamic>.from(response);
      final data = (root['data'] is Map<String, dynamic>)
          ? Map<String, dynamic>.from(root['data'])
          : <String, dynamic>{};

      final userFromData =
          (data['user'] is Map<String, dynamic>) ? Map<String, dynamic>.from(data['user']) : <String, dynamic>{};
      final userFromRoot =
          (root['user'] is Map<String, dynamic>) ? Map<String, dynamic>.from(root['user']) : <String, dynamic>{};

      final token = (root['token'] ?? data['token'] ?? '').toString().trim();
      final rawRole =
          (userFromData['role'] ?? userFromRoot['role'] ?? data['role'] ?? root['role'] ?? '')
              .toString()
              .trim();

      if (token.isEmpty || rawRole.isEmpty) {
        throw Exception('Token أو Role مفقود');
      }

      final normalizedRole = _normalizeRole(rawRole);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', token);
      await prefs.setString('role', normalizedRole);

      return {'token': token, 'role': normalizedRole};
    } on DioException catch (e) {
      final serverMessage = e.response?.data is Map<String, dynamic>
          ? (e.response?.data['message']?.toString() ?? e.response?.data['error']?.toString())
          : null;
      throw Exception(serverMessage?.isNotEmpty == true ? serverMessage : 'فشل تسجيل الدخول');
    }
  }

  String _normalizeRole(String role) {
    final value = role.toLowerCase();
    if (value.contains('admin')) return 'admin';
    if (value.contains('operation')) return 'operation';
    return role;
  }

  @override
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
