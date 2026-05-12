import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'api_service.dart';

class FoodService {
  static const String baseUrl = ApiService.baseUrl;

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  Map<String, String> _authHeaders(String token) => {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      };

  // ─── SCAN ────────────────────────────────────────────────────────────

  /// Upload a food image for scanning.
  /// Returns the full JSON response body (contains `scan_id`).
  Future<Map<String, dynamic>> scanFood(File imageFile) async {
    final token = await _getToken();
    if (token == null) throw Exception("Not authenticated");

    final url = Uri.parse('$baseUrl/user/food/scan');
    print("📸 [SCAN]: Uploading image to $url");

    final request = http.MultipartRequest('POST', url)
      ..headers['Authorization'] = 'Bearer $token'
      ..files.add(await http.MultipartFile.fromPath('image', imageFile.path));

    final streamed = await request.send().timeout(const Duration(seconds: 30));
    final response = await http.Response.fromStream(streamed);

    print("📸 [SCAN]: Status ${response.statusCode}");

    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } else {
      final body = jsonDecode(response.body);
      throw Exception(body['message'] ?? body['error'] ?? 'Scan failed');
    }
  }

  /// Analyze a previously scanned food image.
  /// Returns the full JSON response body with nutrition data.
  Future<Map<String, dynamic>> analyzeFood(String scanId) async {
    final token = await _getToken();
    if (token == null) throw Exception("Not authenticated");

    final url = Uri.parse('$baseUrl/user/food/analyze/$scanId');
    print("🔬 [ANALYZE]: POST $url");

    final response = await http
        .post(url, headers: _authHeaders(token))
        .timeout(const Duration(seconds: 60));

    print("🔬 [ANALYZE]: Status ${response.statusCode}");

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } else {
      final body = jsonDecode(response.body);
      throw Exception(body['message'] ?? body['error'] ?? 'Analysis failed');
    }
  }

  /// Get a previously saved scan result.
  Future<Map<String, dynamic>> getScan(String scanId) async {
    final token = await _getToken();
    if (token == null) throw Exception("Not authenticated");

    final url = Uri.parse('$baseUrl/user/food/scans/$scanId');
    final response = await http
        .get(url, headers: _authHeaders(token))
        .timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } else {
      final body = jsonDecode(response.body);
      throw Exception(body['message'] ?? body['error'] ?? 'Failed to get scan');
    }
  }

  // ─── FOOD LOG ────────────────────────────────────────────────────────

  /// Log food. Supports three modes:
  /// - By scan_id: `{"scan_id": "..."}`
  /// - By name (AI): `{"food_name": "..."}`
  /// - Manual: `{"food_name": "...", "calories": ..., "protein": ..., ...}`
  Future<Map<String, dynamic>> logFood(Map<String, dynamic> data) async {
    final token = await _getToken();
    if (token == null) throw Exception("Not authenticated");

    final url = Uri.parse('$baseUrl/user/food/log');
    print("📝 [LOG]: POST $url");

    final response = await http
        .post(url,
            headers: _authHeaders(token), body: jsonEncode(data))
        .timeout(const Duration(seconds: 15));

    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } else {
      final body = jsonDecode(response.body);
      throw Exception(body['message'] ?? body['error'] ?? 'Log failed');
    }
  }

  // ─── FOOD HISTORY ────────────────────────────────────────────────────

  /// Get food history (grouped meals + daily totals).
  Future<Map<String, dynamic>> getFoodHistory() async {
    final token = await _getToken();
    if (token == null) throw Exception("Not authenticated");

    final url = Uri.parse('$baseUrl/user/food/history');
    final response = await http
        .get(url, headers: _authHeaders(token))
        .timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } else {
      final body = jsonDecode(response.body);
      throw Exception(
          body['message'] ?? body['error'] ?? 'Failed to get history');
    }
  }

  // ─── FOOD SEARCH ─────────────────────────────────────────────────────

  /// Search food database.
  /// [tab] can be: 'all', 'my_meals', 'my_foods', 'saved_scans'
  Future<Map<String, dynamic>> searchFood(String query, {String tab = 'all'}) async {
    final token = await _getToken();
    if (token == null) throw Exception("Not authenticated");

    final url = Uri.parse('$baseUrl/user/food/search?query=$query&tab=$tab');
    print("🔍 [SEARCH]: GET $url");

    final response = await http
        .get(url, headers: _authHeaders(token))
        .timeout(const Duration(seconds: 15));

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } else {
      final body = jsonDecode(response.body);
      throw Exception(
          body['message'] ?? body['error'] ?? 'Search failed');
    }
  }

  // ─── SERVING / NUTRITION DETAILS ─────────────────────────────────────

  /// Get serving/nutrition details for a food item.
  /// [source] is required: 'usda_fdc', 'open_food_facts', 'saved_scans', 'my_meals', 'my_foods'
  Future<Map<String, dynamic>> getServing({
    required String source,
    String? fdcId,
    String? barcode,
    String? scanId,
    String? logId,
  }) async {
    final token = await _getToken();
    if (token == null) throw Exception("Not authenticated");

    final params = <String, String>{'source': source};
    if (fdcId != null) params['fdc_id'] = fdcId;
    if (barcode != null) params['barcode'] = barcode;
    if (scanId != null) params['scan_id'] = scanId;
    if (logId != null) params['log_id'] = logId;

    final url = Uri.parse('$baseUrl/user/food/database/serving')
        .replace(queryParameters: params);
    print("📊 [SERVING]: GET $url");

    final response = await http
        .get(url, headers: _authHeaders(token))
        .timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } else {
      final body = jsonDecode(response.body);
      throw Exception(
          body['message'] ?? body['error'] ?? 'Failed to get serving info');
    }
  }

  // ─── CALORIE PLAN ────────────────────────────────────────────────────

  /// Get the user's calorie plan.
  /// May return `missing_fields` if the profile is incomplete.
  Future<Map<String, dynamic>> getCaloriePlan() async {
    final token = await _getToken();
    if (token == null) throw Exception("Not authenticated");

    final url = Uri.parse('$baseUrl/user/plan/calories');
    print("🎯 [PLAN]: GET $url");

    final response = await http
        .get(url, headers: _authHeaders(token))
        .timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } else {
      final body = jsonDecode(response.body);
      throw Exception(
          body['message'] ?? body['error'] ?? 'Failed to get plan');
    }
  }
}
