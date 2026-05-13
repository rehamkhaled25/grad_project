import 'dart:convert';

import 'package:graduation_project/models/plan_model.dart';
import 'package:graduation_project/models/user_model.dart';
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
    double? goalWeight,
    List<String>? allergies,
  }) async {
    final url = Uri.parse('$baseUrl/user/profile');
    final token = await _getToken();

    //
    print("🚀 [SAVE ONBOARDING] Sending PUT to $url");
    print("   token present : ${token != null}");
    print("   fullName      : $fullName");
    print("   birthdate     : $birthdate");
    print("   gender        : $gender");
    print("   goal          : $goal");
    print("   weight        : $weight");
    print("   height        : $height");
    print("   goalWeight    : $goalWeight");
    print("   allergies     : $allergies");

    if (token == null) {
      print("❌ [SAVE ONBOARDING] No token found — user is not logged in");
      throw Exception("No authentication token found. Please login again.");
    }

    final body = jsonEncode({
      if (fullName.isNotEmpty) "full_name": fullName,
      "birthdate": birthdate,
      "gender": gender,
      "goal": goal,
      "weight": weight,
      "height": height,
      "goal_weight": goalWeight,
      "allergies": allergies ?? [],
    });

    try {
      final response = await http
          .put(
            url,
            headers: {
              "Content-Type": "application/json",
              "Authorization": "Bearer $token",
            },
            body: body,
          )
          .timeout(const Duration(seconds: 30));

      print("📡 [SAVE ONBOARDING] Response status : ${response.statusCode}");
      print("📡 [SAVE ONBOARDING] Response body   : ${response.body}");

      if (response.statusCode == 200) {
        print("✅ [SAVE ONBOARDING] Profile saved successfully");
        return true;
      } else {
        print(
          "❌ [SAVE ONBOARDING] Server rejected with ${response.statusCode}: ${response.body}",
        );
        return false;
      }
    } catch (e) {
      print("🔥 [SAVE ONBOARDING] Exception: $e");
      rethrow;
    }
  }

  Future<UserModel?> getUserProfile() async {
    final url = Uri.parse('$baseUrl/user/profile');
    final token = await _getToken();

    print("🚀 [GET PROFILE] Fetching from $url");
    print("   token present: ${token != null}");

    try {
      final response = await http.get(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      print("📡 [GET PROFILE] Response status : ${response.statusCode}");
      print("📡 [GET PROFILE] Response body   : ${response.body}");

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);

        if (data.containsKey('user')) {
          return UserModel.fromJson(data['user']);
        }
        return UserModel.fromJson(data);
      } else {
        print("❌ [GET PROFILE] Server error: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      print("🔥 [GET PROFILE] Exception: $e");
      return null;
    }
  }

  Future<PlanModel?> getCalculatedPlan() async {
    final url = Uri.parse('$baseUrl/user/plan/calories');
    final token = await _getToken();

    try {
      final response = await http.get(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return PlanModel.fromJson(data);
      }
      return null;
    } catch (e) {
      print("Error fetching plan: $e");
      return null;
    }
  }
}
