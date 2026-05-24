import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
 
class ApiService {
  // static const String baseUrl = "http://192.168.1.3:5000";
  static const String baseUrl = "http://10.0.2.2:5000"; 
  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }
 
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }
 
  // Clears the token so the user is fully logged out
  Future<void> deleteToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
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
          .timeout(const Duration(seconds: 10));
 
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
        final userData = data['user'] ?? data;
        return UserModel.fromJson(userData);
      }
      return null;
    } catch (e) {
      print("⚠️ [PROFILE FETCH ERROR]: $e");
      return null;
    }
  }
 
  /// Upload a profile image.
  /// Returns the updated profile_image_url on success, null on failure.
  Future<String?> uploadProfileImage(String imagePath) async {
    final url = Uri.parse('$baseUrl/user/profile/image');
    final token = await getToken();
    if (token == null) return null;
 
    print("📷 [PROFILE IMAGE]: Uploading to $url");
 
    try {
      final request = http.MultipartRequest('POST', url)
        ..headers['Authorization'] = 'Bearer $token'
        ..files.add(await http.MultipartFile.fromPath('image', imagePath));
 
      final streamed =
          await request.send().timeout(const Duration(seconds: 30));
      final response = await http.Response.fromStream(streamed);
 
      print("📷 [PROFILE IMAGE]: Status ${response.statusCode}");
 
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['profile_image_url'] as String?;
      }
      return null;
    } catch (e) {
      print("⚠️ [PROFILE IMAGE ERROR]: $e");
      return null;
    }
  }
 
  /// Updates the allergies list on the backend by fetching the current profile
  /// first (to preserve all other fields), then PUTting the full profile back
  /// with the new allergies list.
  /// Returns true on success, false on failure.
  Future<bool> updateAllergies(List<String> allergies) async {
    final token = await getToken();
    if (token == null) {
      print("❌ [UPDATE ALLERGIES] No token found — user is not logged in");
      return false;
    }
 
    // Fetch the current profile so we don't overwrite other fields
    final currentProfile = await getProfile();
    if (currentProfile == null) {
      print("❌ [UPDATE ALLERGIES] Could not fetch current profile");
      return false;
    }
 
    final url = Uri.parse('$baseUrl/user/profile');
 
    final body = jsonEncode({
      if ((currentProfile.fullName ?? '').isNotEmpty)
        "full_name": currentProfile.fullName,
      "birthdate": currentProfile.birthdate,
      "gender": currentProfile.gender,
      "goal": currentProfile.goal,
      "weight": currentProfile.weight,
      "height": currentProfile.height,
      "goal_weight": currentProfile.goalWeight,
      "allergies": allergies,
    });
 
    print("🚀 [UPDATE ALLERGIES] Sending PUT to $url");
    print("   allergies: $allergies");
 
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
 
      print("📡 [UPDATE ALLERGIES] Status : ${response.statusCode}");
      print("📡 [UPDATE ALLERGIES] Body   : ${response.body}");
 
      if (response.statusCode == 200) {
        print("✅ [UPDATE ALLERGIES] Allergies saved successfully");
        return true;
      } else {
        print("❌ [UPDATE ALLERGIES] Server rejected: ${response.statusCode}");
        return false;
      }
    } catch (e) {
      print("🔥 [UPDATE ALLERGIES] Exception: $e");
      return false;
    }
  }
}