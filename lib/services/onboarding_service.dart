import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingService {
  static const String baseUrl = "http://192.168.1.3:5000";

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  Future<bool> saveOnboardingData({
    required String fullName,
    required String birthdate,
    required String gender,
    required String goal,
    required double weight,
    required double height,
  }) async {
    final url = Uri.parse('$baseUrl/user/profile');
    final token = await _getToken();

    print("🔗 [ONBOARDING]: Attempting PUT to $url");
    print("🔑 [TOKEN]: ${token != null ? 'Token Found' : 'MISSING TOKEN'}");

    if (token == null) {
      print("❌ [ERROR]: Cannot save onboarding because user is not logged in (Token null)");
      throw Exception("No authentication token found. Please login again.");
    }

    try {
      final response = await http.put(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode({
          "full_name": fullName,
          "birthdate": birthdate,
          "gender": gender,
          "goal": goal,
          "weight": weight,
          "height": height,
        }),
      ).timeout(const Duration(seconds: 10));

      print("✅ [ONBOARDING]: Status: ${response.statusCode}");

      if (response.statusCode == 200) {
        return true;
      } else {
        final errorBody = jsonDecode(response.body);
        print("❌ [FAILED]: ${errorBody['message']}");
        return false;
      }
    } catch (e) {
      print("🔥 [EXCEPTION]: $e");
      return false;
    }
  }
}