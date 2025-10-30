import 'package:disctop_app/core/api_service.dart';
import 'package:disctop_app/features/auth/auth_repository/auth_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthRepositoryImpl implements AuthRepository {
  final ApiService api;
  AuthRepositoryImpl(this.api);

  @override
  Future<Map<String, String>> login(String email, String password) async {
    final response = await api.login(email, password);
    final data = response['data'] as Map<String, dynamic>?;

    if (data == null) throw Exception("بيانات غير صالحة");
    final token = data['token'] as String?;
    final role  = (data['user'] as Map<String, dynamic>?)?['role'] as String?;
    if (token == null || role == null) throw Exception("Token أو Role مفقود");

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
    await prefs.setString('role', role);

    return {'token': token, 'role': role};
  }

  @override
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
