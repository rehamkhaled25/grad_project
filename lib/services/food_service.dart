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
      return Map<String, dynamic>.from(jsonDecode(response.body));
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
      return Map<String, dynamic>.from(jsonDecode(response.body));
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
      return Map<String, dynamic>.from(jsonDecode(response.body));
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
      return Map<String, dynamic>.from(jsonDecode(response.body));
    } else {
      final body = jsonDecode(response.body);
      throw Exception(body['message'] ?? body['error'] ?? 'Log failed');
    }
  }

  // ─── FOOD HISTORY ────────────────────────────────────────────────────

  /// Get food history (grouped meals + daily totals).
  /// Optionally filter by [date] (format: YYYY-MM-DD).
  Future<Map<String, dynamic>> getFoodHistory({String? date}) async {
    final token = await _getToken();
    if (token == null) throw Exception("Not authenticated");

    String urlStr = '$baseUrl/user/food/history';
    if (date != null) urlStr += '?date=$date';

    final url = Uri.parse(urlStr);
    final response = await http
        .get(url, headers: _authHeaders(token))
        .timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      return Map<String, dynamic>.from(jsonDecode(response.body));
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
      return Map<String, dynamic>.from(jsonDecode(response.body));
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
      return Map<String, dynamic>.from(jsonDecode(response.body));
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
      return Map<String, dynamic>.from(jsonDecode(response.body));
    } else {
      final body = jsonDecode(response.body);
      throw Exception(
          body['message'] ?? body['error'] ?? 'Failed to get plan');
    }
  }

  // ─── PLAN APPLY (Premium / Mock Payment) ─────────────────────────────

  /// Apply a plan (mock payment confirmation).
  /// [planId] is the plan to activate.
  Future<Map<String, dynamic>> applyPlan(int planId) async {
    final token = await _getToken();
    if (token == null) throw Exception("Not authenticated");

    final url = Uri.parse('$baseUrl/user/plan/apply');
    print("💳 [PLAN APPLY]: POST $url with plan_id=$planId");

    final response = await http
        .post(url,
            headers: _authHeaders(token),
            body: jsonEncode({'plan_id': planId}))
        .timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      return Map<String, dynamic>.from(jsonDecode(response.body));
    } else {
      final body = jsonDecode(response.body);
      throw Exception(
          body['message'] ?? body['error'] ?? 'Failed to apply plan');
    }
  }

  // ─── DAILY PROGRESS (computed from history + plan) ───────────────────

  /// Get daily progress: consumed totals vs goals for a given date.
  Future<Map<String, dynamic>> getDailyProgress({String? date}) async {
    final dateStr = date ??
        DateTime.now().toIso8601String().substring(0, 10);

    final results = await Future.wait([
      getFoodHistory(date: dateStr).catchError((_) => <String, dynamic>{}),
      getCaloriePlan().catchError((_) => <String, dynamic>{}),
    ]);

    final history = results[0] as Map<String, dynamic>;
    final plan = results[1] as Map<String, dynamic>;
    final totals = history['totals'] is Map ? Map<String, dynamic>.from(history['totals']) : <String, dynamic>{};

    final goalCalories = (plan['calories'] ?? 2400).toDouble();
    final goalProtein = (plan['protein'] ?? 120).toDouble();
    final goalCarbs = (plan['carbs'] ?? 250).toDouble();
    final goalFats = (plan['fats'] ?? 60).toDouble();

    final consumed = (totals['calories'] ?? 0).toDouble();
    final consumedProtein = (totals['protein'] ?? 0).toDouble();
    final consumedCarbs = (totals['carbs'] ?? 0).toDouble();
    final consumedFats = (totals['fats'] ?? 0).toDouble();

    // Compute health score client-side (0-10)
    final calRatio = goalCalories > 0 ? consumed / goalCalories : 0.0;
    final protRatio = goalProtein > 0 ? consumedProtein / goalProtein : 0.0;
    final carbRatio = goalCarbs > 0 ? consumedCarbs / goalCarbs : 0.0;
    final fatRatio = goalFats > 0 ? consumedFats / goalFats : 0.0;

    // Score based on how close to targets (1.0 = perfect)
    double avgDeviation = 0;
    int count = 0;
    for (final ratio in [calRatio, protRatio, carbRatio, fatRatio]) {
      if (ratio > 0) {
        avgDeviation += (1.0 - ratio).abs();
        count++;
      }
    }
    avgDeviation = count > 0 ? avgDeviation / count : 1.0;

    // Convert to 0-10 score (lower deviation = higher score)
    int healthScore = ((1.0 - avgDeviation.clamp(0.0, 1.0)) * 10).round();
    healthScore = healthScore.clamp(0, 10);

    return {
      'date': dateStr,
      'consumed': {
        'calories': consumed,
        'protein': consumedProtein,
        'carbs': consumedCarbs,
        'fats': consumedFats,
      },
      'goals': {
        'calories': goalCalories,
        'protein': goalProtein,
        'carbs': goalCarbs,
        'fats': goalFats,
      },
      'progress': goalCalories > 0 ? (consumed / goalCalories).clamp(0.0, 1.0) : 0.0,
      'health_score': healthScore,
      'grouped': history['grouped'] ?? {},
      'logs': history['logs'] ?? [],
    };
  }

  /// Get weekly progress: array of 7 days of daily totals.
  Future<List<Map<String, dynamic>>> getWeeklyProgress() async {
    final now = DateTime.now();
    final List<Future<Map<String, dynamic>>> futures = [];

    for (int i = 6; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final dateStr = date.toIso8601String().substring(0, 10);
      futures.add(
        getFoodHistory(date: dateStr)
            .then((data) {
              final totals = data['totals'] is Map ? Map<String, dynamic>.from(data['totals']) : <String, dynamic>{};
              return {
                'date': dateStr,
                'calories': (totals['calories'] ?? 0).toDouble(),
                'protein': (totals['protein'] ?? 0).toDouble(),
                'carbs': (totals['carbs'] ?? 0).toDouble(),
                'fats': (totals['fats'] ?? 0).toDouble(),
                'meal_count': ((data['logs'] as List?)?.length ?? 0),
              };
            })
            .catchError((_) => {
                  'date': dateStr,
                  'calories': 0.0,
                  'protein': 0.0,
                  'carbs': 0.0,
                  'fats': 0.0,
                  'meal_count': 0,
                }),
      );
    }

    return Future.wait(futures);
  }

  // ─── STREAK (computed from food history) ─────────────────────────────

  /// Calculate streak from food history.
  /// Checks last 90 days for consecutive days with logged food.
  Future<Map<String, dynamic>> getStreak() async {
    final token = await _getToken();
    if (token == null) throw Exception("Not authenticated");

    final now = DateTime.now();
    final Set<String> loggedDates = {};

    // Fetch last 90 days of history to find logged dates
    // We'll batch by fetching all history without date filter
    // and extracting unique dates from log_time
    try {
      final history = await getFoodHistory();
      final logs = (history['logs'] as List?) ?? [];

      for (final log in logs) {
        final logTime = log['log_time']?.toString() ?? '';
        if (logTime.length >= 10) {
          loggedDates.add(logTime.substring(0, 10));
        }
      }
    } catch (_) {}

    // Calculate current streak
    int currentStreak = 0;
    for (int i = 0; i < 365; i++) {
      final date = now.subtract(Duration(days: i));
      final dateStr = date.toIso8601String().substring(0, 10);
      if (loggedDates.contains(dateStr)) {
        currentStreak++;
      } else if (i > 0) {
        // Skip today if no food logged yet
        break;
      }
    }

    // Calculate longest streak
    int longestStreak = 0;
    int tempStreak = 0;
    final sortedDates = loggedDates.toList()..sort();
    for (int i = 0; i < sortedDates.length; i++) {
      if (i == 0) {
        tempStreak = 1;
      } else {
        final prev = DateTime.parse(sortedDates[i - 1]);
        final curr = DateTime.parse(sortedDates[i]);
        if (curr.difference(prev).inDays == 1) {
          tempStreak++;
        } else {
          tempStreak = 1;
        }
      }
      if (tempStreak > longestStreak) longestStreak = tempStreak;
    }

    final todayStr = now.toIso8601String().substring(0, 10);
    final isActive = loggedDates.contains(todayStr);

    return {
      'streak_count': currentStreak,
      'longest_streak': longestStreak,
      'is_active': isActive,
      'logged_days': loggedDates.toList(),
      'total_days_logged': loggedDates.length,
    };
  }

  // ─── BADGES (computed client-side) ───────────────────────────────────

  /// Compute badges based on user activity.
  Future<List<Map<String, dynamic>>> getBadges() async {
    final streak = await getStreak().catchError((_) => <String, dynamic>{});
    final streakCount = (streak['streak_count'] ?? 0) as int;
    final totalDays = (streak['total_days_logged'] ?? 0) as int;

    return [
      {
        'key': 'active_starter',
        'title': 'Active\nStarter',
        'icon': 'rocket_launch',
        'is_earned': totalDays >= 1,
        'is_new': totalDays >= 1 && totalDays < 3,
        'category': 'featured',
      },
      {
        'key': 'high_achiever',
        'title': 'High\nAchiever',
        'icon': 'access_time',
        'is_earned': streakCount >= 7,
        'is_new': false,
        'category': 'featured',
      },
      {
        'key': 'eager_learner',
        'title': 'Eager\nLearner',
        'icon': 'menu_book',
        'is_earned': totalDays >= 14,
        'is_new': false,
        'category': 'featured',
      },
      {
        'key': 'serious_tracker',
        'title': 'Serious\nTracker',
        'icon': 'auto_awesome',
        'is_earned': totalDays >= 30,
        'is_new': false,
        'category': 'featured',
      },
      {
        'key': 'confident_logger',
        'title': 'Confident\nLogger',
        'icon': 'flag',
        'is_earned': streakCount >= 14,
        'is_new': streakCount >= 14 && streakCount < 21,
        'category': 'featured',
      },
      {
        'key': 'streak_master',
        'title': 'Streak\nMaster',
        'icon': 'shield',
        'is_earned': streakCount >= 30,
        'is_new': false,
        'category': 'featured',
      },
      {
        'key': 'hot_week',
        'title': 'Hot Week',
        'icon': 'local_fire_department',
        'is_earned': streakCount >= 7,
        'is_new': false,
        'category': 'weekly',
        'level': 1,
      },
      {
        'key': 'super_week',
        'title': 'Super Week',
        'icon': 'eco',
        'is_earned': streakCount >= 14,
        'is_new': false,
        'category': 'weekly',
        'level': 2,
      },
      {
        'key': 'ultra_week',
        'title': 'Ultra Week',
        'icon': 'local_fire_department',
        'is_earned': streakCount >= 21,
        'is_new': false,
        'category': 'weekly',
        'level': 3,
      },
      {
        'key': 'mega_week',
        'title': 'Mega Week',
        'icon': 'bubble_chart',
        'is_earned': streakCount >= 28,
        'is_new': false,
        'category': 'weekly',
        'level': 4,
      },
    ];
  }

  // ─── RECENT SCANS ───────────────────────────────────────────────────

  /// Get recent food scans.
  Future<Map<String, dynamic>> getRecentScans({int limit = 20}) async {
    final token = await _getToken();
    if (token == null) throw Exception("Not authenticated");

    final url = Uri.parse('$baseUrl/user/food/scans/recent?limit=$limit');
    final response = await http
        .get(url, headers: _authHeaders(token))
        .timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      return Map<String, dynamic>.from(jsonDecode(response.body));
    } else {
      final body = jsonDecode(response.body);
      throw Exception(
          body['message'] ?? body['error'] ?? 'Failed to get recent scans');
    }
  }
}
