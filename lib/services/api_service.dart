import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';

class ApiService {
  static const String baseUrl = "http://10.0.2.2:5000";

  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  Future<http.Response> register(UserModel user) async {
    final url = Uri.parse('$baseUrl/auth/register');
    print("🔗 [CHECKPOINT 2]: POST Request to $url");

    try {
      final response = await http
          .post(
            url,
            headers: {"Content-Type": "application/json"},
            body: jsonEncode({
              "full_name": user.fullName,
              "email": user.email,
              "password": user.password,
            }),
          )
          .timeout(const Duration(seconds: 10)); // Stop waiting after 10s

      return response;
    } catch (e) {
      print("⚠️ [NETWORK ERROR]: Failed to reach $url. Error: $e");
      throw Exception("Signup Error: $e");
    }
  }

  Future<http.Response> login(String email, String password) async {
    final url = Uri.parse('$baseUrl/auth/login');
    print("🔗 [CHECKPOINT 2]: Logging in at $url");
    try {
      final response = await http
          .post(
            url,
            headers: {"Content-Type": "application/json"},
            body: jsonEncode({"email": email, "password": password}),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        await saveToken(data['token']);
      }
      return response;
    } catch (e) {
      print("⚠️ [LOGIN ERROR]: $e");
      throw Exception("Login Error: $e");
    }
  }

  Future<UserModel?> getProfile() async {
    final url = Uri.parse('$baseUrl/user/profile');
    final token = await getToken();
    print("🔗 [CHECKPOINT 2]: Fetching profile from $url");

    try {
      final response = await http
          .get(
            url,
            headers: {
              "Content-Type": "application/json",
              "Authorization": "Bearer $token",
            },
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return UserModel.fromJson(data['user']);
      }
      return null;
    } catch (e) {
      print("⚠️ [PROFILE FETCH ERROR]: $e");
      return null;
    }
  }
}
