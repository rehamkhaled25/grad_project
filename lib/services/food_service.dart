import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'api_service.dart';

class FoodService {
  static const String baseUrl = ApiService.baseUrl;
  static DateTime globalSelectedDate = DateTime.now();
  static bool needsRefresh = false;

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
  Future<Map<String, dynamic>> analyzeFood(String scanId, {String? context}) async {
    final token = await _getToken();
    if (token == null) throw Exception("Not authenticated");

    final url = Uri.parse('$baseUrl/user/food/analyze/$scanId');
    print("🔬 [ANALYZE]: POST $url");

    final body = context != null ? jsonEncode({"context": context}) : null;

    final response = await http
        .post(url, headers: _authHeaders(token), body: body)
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

  /// Log food to the backend.
  ///
  /// The [data] map must contain at minimum `food_name` and the nutritional
  /// values (`calories`, `protein`, `carbs`, `fats`).
  ///
  /// Include `meal_type` (breakfast/lunch/dinner/snack) in [data] so the
  /// backend stores the entry in the correct meal bucket.
  ///
  /// Include `image_url` in [data] if you want the image to persist and
  /// show up in the dashboard / My Meals / My Foods tabs.
  Future<Map<String, dynamic>> logFood(Map<String, dynamic> data) async {
    final token = await _getToken();
    if (token == null) throw Exception("Not authenticated");

    final url = Uri.parse('$baseUrl/user/food/log');
    print("📝 [LOG]: POST $url  meal_type=${data['meal_type']}");

    final response = await http
        .post(url,
            headers: _authHeaders(token), body: jsonEncode(data))
        .timeout(const Duration(seconds: 15));

    if (response.statusCode == 200 || response.statusCode == 201) {
      needsRefresh = true;
      return Map<String, dynamic>.from(jsonDecode(response.body));
    } else {
      final body = jsonDecode(response.body);
      throw Exception(body['message'] ?? body['error'] ?? 'Log failed');
    }
  }

  /// Delete a food log entry.
  Future<void> deleteFoodLog(int logId) async {
    final token = await _getToken();
    if (token == null) throw Exception("Not authenticated");

    final url = Uri.parse('$baseUrl/user/food/log/$logId');
    print("🗑️ [DELETE LOG]: DELETE $url");

    final response = await http
        .delete(url, headers: _authHeaders(token))
        .timeout(const Duration(seconds: 10));

    if (response.statusCode != 200) {
      final body = jsonDecode(response.body);
      throw Exception(body['message'] ?? body['error'] ?? 'Delete failed');
    }
    needsRefresh = true;
  }

  /// Update/edit a food log entry.
  Future<Map<String, dynamic>> updateFoodLog(int logId, Map<String, dynamic> data) async {
    final token = await _getToken();
    if (token == null) throw Exception("Not authenticated");

    final url = Uri.parse('$baseUrl/user/food/log/$logId');
    print("✏️ [UPDATE LOG]: PUT $url");

    final response = await http
        .put(url, headers: _authHeaders(token), body: jsonEncode(data))
        .timeout(const Duration(seconds: 15));

    if (response.statusCode == 200) {
      needsRefresh = true;
      return Map<String, dynamic>.from(jsonDecode(response.body));
    } else {
      final body = jsonDecode(response.body);
      throw Exception(body['message'] ?? body['error'] ?? 'Update failed');
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
  /// [query] empty string is fine — for my_meals/my_foods/saved_scans the
  /// backend returns all recent entries when query is empty.
  Future<Map<String, dynamic>> searchFood(String query,
      {String tab = 'all'}) async {
    final token = await _getToken();
    if (token == null) throw Exception("Not authenticated");

    final encodedQuery = Uri.encodeQueryComponent(query.trim());
    final url =
        Uri.parse('$baseUrl/user/food/search?query=$encodedQuery&tab=$tab');
    print("🔍 [SEARCH]: GET $url");

    final response = await http
        .get(url, headers: _authHeaders(token))
        .timeout(const Duration(seconds: 15));

    if (response.statusCode == 200) {
      final data = Map<String, dynamic>.from(jsonDecode(response.body));
      final List rawResults = data['results'] ?? [];
      final enriched = await _enrichLogsWithImages(rawResults);
      data['results'] = enriched;
      return data;
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
    final prefs = await SharedPreferences.getInstance();
    final email = await ApiService().getCurrentUserEmail() ?? '';
    final prefix = email.isNotEmpty ? '${email}_' : '';
    final double? overrideCalories = prefs.getDouble('${prefix}plan_calories');
    final double? overrideProtein = prefs.getDouble('${prefix}plan_protein');
    final double? overrideFats = prefs.getDouble('${prefix}plan_fats');
    final double? overrideCarbs = prefs.getDouble('${prefix}plan_carbs');

    final token = await _getToken();
    if (token == null) throw Exception("Not authenticated");

    final url = Uri.parse('$baseUrl/user/plan/calories');
    print("🎯 [PLAN]: GET $url");

    Map<String, dynamic> planData = {};
    try {
      final response = await http
          .get(url, headers: _authHeaders(token))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        planData = Map<String, dynamic>.from(jsonDecode(response.body));
      } else {
        final body = jsonDecode(response.body);
        throw Exception(
            body['message'] ?? body['error'] ?? 'Failed to get plan');
      }
    } catch (e) {
      print("🎯 [PLAN]: Error loading plan from backend: $e");
    }

    if (overrideCalories != null) planData['calories'] = overrideCalories;
    if (overrideProtein != null) planData['protein'] = overrideProtein;
    if (overrideFats != null) planData['fats'] = overrideFats;
    if (overrideCarbs != null) planData['carbs'] = overrideCarbs;

    return planData;
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

  // ─── IMAGE ENRICHMENT HELPERS ────────────────────────────────────────

  /// Fetches the publicly accessible image URL for a given scan_id.
  /// The backend returns image_path (a filesystem path). We derive the
  /// served URL from the filename using /user/food/scans/image/<filename>.
  Future<String?> getScanImageUrl(String scanId) async {
    try {
      final scanData = await getScan(scanId);

      // Prefer image_url if the backend already sends a full URL
      final imageUrl = scanData['scan']?['image_url']?.toString() ??
          scanData['image_url']?.toString();
      if (imageUrl != null && imageUrl.isNotEmpty) {
        return imageUrl.startsWith('http') ? imageUrl : '$baseUrl/$imageUrl';
      }

      // Fallback: derive URL from image_path (strip to filename only)
      final imagePath = scanData['scan']?['image_path']?.toString() ??
          scanData['image_path']?.toString();
      if (imagePath != null && imagePath.isNotEmpty) {
        final filename = imagePath.split('/').last.split('\\').last;
        return '$baseUrl/user/food/scans/image/$filename';
      }
    } catch (_) {}
    return null;
  }

  /// Takes a raw list of log-entry maps and returns them enriched with
  /// an `image_url` field wherever possible:
  ///   - Scan-based logs:  fetched via getScanImageUrl(scan_id)
  ///   - Database logs:    the `image_url` key already present is used as-is
  Future<List<Map<String, dynamic>>> _enrichLogsWithImages(
      List<dynamic> rawLogs) async {
    final futures = rawLogs.map((raw) async {
      final log = Map<String, dynamic>.from(raw as Map);

      // 1. Check if it already has a usable image URL
      final existing = log['image_url']?.toString() ?? '';
      if (existing.isNotEmpty && existing != 'null') {
        log['image_url'] = existing.startsWith('http')
            ? existing
            : '$baseUrl/${existing.startsWith('/') ? existing.substring(1) : existing}';
        return log;
      }

      // 2. Check if it carries a raw image_path in the database
      final rawPath = log['image_path']?.toString() ?? '';
      if (rawPath.isNotEmpty && rawPath != 'null') {
        if (rawPath.startsWith('http')) {
          log['image_url'] = rawPath;
        } else if (rawPath.contains('\\') || rawPath.contains('/')) {
          final filename = rawPath.split('/').last.split('\\').last;
          log['image_url'] = '$baseUrl/user/food/scans/image/$filename';
        } else {
          log['image_url'] = '$baseUrl/${rawPath.startsWith('/') ? rawPath.substring(1) : rawPath}';
        }
        return log;
      }

      // 3. Try to get the image from the linked scan if scan_id is present
      final scanId = log['scan_id']?.toString() ?? '';
      if (scanId.isNotEmpty && scanId != 'null') {
        final url = await getScanImageUrl(scanId);
        if (url != null) {
          log['image_url'] = url;
          return log;
        }
      }

      // 4. Fallback: if it's a saved scan and has no scan_id field, but the entry itself is a scan
      final isSavedScan = log['fdc_id'] == null && log['barcode'] == null && log['meal_type'] == null;
      if (isSavedScan) {
        final logId = log['id']?.toString() ?? '';
        if (logId.isNotEmpty && logId != 'null') {
          final url = await getScanImageUrl(logId);
          if (url != null) log['image_url'] = url;
        }
      }

      return log;
    });

    return Future.wait(futures);
  }

  /// Enriches every meal list inside a grouped map (breakfast/lunch/dinner/snack).
  Future<Map<String, dynamic>> _enrichGroupedWithImages(
      Map<String, dynamic> grouped) async {
    final result = <String, dynamic>{};
    for (final entry in grouped.entries) {
      result[entry.key] = (entry.value is List)
          ? await _enrichLogsWithImages(entry.value as List)
          : entry.value;
    }
    return result;
  }

  // ─── DAY PROGRESS ────────────────────────────────────────────────────

  /// Fetch progress for a single day from GET /user/progress/day?date=YYYY-MM-DD.
  /// Falls back to composing from food history + calorie plan if the dedicated
  /// endpoint doesn't exist yet on the backend.
  ///
  /// Returns a map with keys:
  ///   date, calories, protein, carbs, fats,
  ///   goal_calories, goal_protein, goal_carbs, goal_fats,
  ///   progress (0.0–uncapped), has_data (bool), meals (List), grouped (Map)
  Future<Map<String, dynamic>> getDayProgress(String date) async {
    final prefs = await SharedPreferences.getInstance();
    final email = await ApiService().getCurrentUserEmail() ?? '';
    final prefix = email.isNotEmpty ? '${email}_' : '';
    final double? overrideCalories = prefs.getDouble('${prefix}plan_calories');
    final double? overrideProtein = prefs.getDouble('${prefix}plan_protein');
    final double? overrideFats = prefs.getDouble('${prefix}plan_fats');
    final double? overrideCarbs = prefs.getDouble('${prefix}plan_carbs');

    final token = await _getToken();
    if (token == null) throw Exception("Not authenticated");

    // ── Try the dedicated endpoint first ──────────────────────────────
    try {
      final url = Uri.parse('$baseUrl/user/progress/day?date=$date');
      print("📅 [DAY PROGRESS]: GET $url");

      final response = await http
          .get(url, headers: _authHeaders(token))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = Map<String, dynamic>.from(jsonDecode(response.body));
        final goalCalories = overrideCalories ?? (data['goal_calories'] ?? 2400).toDouble();
        final consumed =
            (data['calories'] ?? data['total_calories'] ?? 0).toDouble();
        final hasData = consumed > 0 || data['has_data'] == true;

        final rawLogs = (data['meals'] ?? data['logs'] ?? []) as List;
        final enrichedLogs = await _enrichLogsWithImages(rawLogs);

        final rawGrouped = data['grouped'] is Map
            ? Map<String, dynamic>.from(data['grouped'] as Map)
            : <String, dynamic>{};
        final enrichedGrouped = await _enrichGroupedWithImages(rawGrouped);

        // progress is uncapped — let the UI decide how to display >1.0
        final progress = goalCalories > 0 ? consumed / goalCalories : 0.0;

        return {
          'date': date,
          'calories': consumed,
          'protein': (data['protein'] ?? data['total_protein'] ?? 0).toDouble(),
          'carbs': (data['carbs'] ?? data['total_carbs'] ?? 0).toDouble(),
          'fats': (data['fats'] ?? data['total_fat'] ?? 0).toDouble(),
          'goal_calories': goalCalories,
          'goal_protein': overrideProtein ?? (data['goal_protein'] ?? 120).toDouble(),
          'goal_carbs': overrideCarbs ?? (data['goal_carbs'] ?? 250).toDouble(),
          'goal_fats': overrideFats ?? (data['goal_fats'] ?? 60).toDouble(),
          'progress': progress,
          'has_data': hasData,
          'meals': enrichedLogs,
          'logs': enrichedLogs,
          'grouped': enrichedGrouped,
        };
      }
    } catch (_) {
      // Fall through to the composed approach below
    }

    // ── Fallback: compose from existing endpoints ─────────────────────
    print("📅 [DAY PROGRESS]: Falling back to history + plan for $date");

    final results = await Future.wait([
      getFoodHistory(date: date).catchError((_) => <String, dynamic>{}),
      getCaloriePlan().catchError((_) => <String, dynamic>{}),
    ]);

    final history = results[0] as Map<String, dynamic>;
    final plan = results[1] as Map<String, dynamic>;

    final totals = history['totals'] is Map
        ? Map<String, dynamic>.from(history['totals'])
        : <String, dynamic>{};

    final goalCalories = overrideCalories ?? (plan['calories'] ?? 2400).toDouble();
    final goalProtein = overrideProtein ?? (plan['protein'] ?? 120).toDouble();
    final goalCarbs = overrideCarbs ?? (plan['carbs'] ?? 250).toDouble();
    final goalFats = overrideFats ?? (plan['fats'] ?? 60).toDouble();

    final calories = (totals['calories'] ?? 0).toDouble();
    final protein = (totals['protein'] ?? 0).toDouble();
    final carbs = (totals['carbs'] ?? 0).toDouble();
    final fats = (totals['fats'] ?? 0).toDouble();

    final rawLogs = history['logs'] is List ? history['logs'] as List : [];
    final enrichedLogs = await _enrichLogsWithImages(rawLogs);

    final rawGrouped = history['grouped'] is Map
        ? Map<String, dynamic>.from(history['grouped'] as Map)
        : <String, dynamic>{};
    final enrichedGrouped = await _enrichGroupedWithImages(rawGrouped);

    final hasData = enrichedLogs.isNotEmpty || calories > 0;

    // progress is uncapped — calories can legitimately exceed the goal
    final progress = goalCalories > 0 ? calories / goalCalories : 0.0;

    return {
      'date': date,
      'calories': calories,
      'protein': protein,
      'carbs': carbs,
      'fats': fats,
      'goal_calories': goalCalories,
      'goal_protein': goalProtein,
      'goal_carbs': goalCarbs,
      'goal_fats': goalFats,
      'progress': progress,
      'has_data': hasData,
      'meals': enrichedLogs,
      'logs': enrichedLogs,
      'grouped': enrichedGrouped,
    };
  }

  // ─── WEEK PROGRESS ───────────────────────────────────────────────────

  /// Fetch progress for the last 8 days (to match the week bar) from
  /// GET /user/progress/week. Falls back to parallel per-day calls.
  ///
  /// Returns a list of day maps (same shape as [getDayProgress]).
  Future<List<Map<String, dynamic>>> getWeekProgress() async {
    final prefs = await SharedPreferences.getInstance();
    final email = await ApiService().getCurrentUserEmail() ?? '';
    final prefix = email.isNotEmpty ? '${email}_' : '';
    final double? overrideCalories = prefs.getDouble('${prefix}plan_calories');

    final token = await _getToken();
    if (token == null) throw Exception("Not authenticated");

    // ── Try dedicated endpoint first ──────────────────────────────────
    try {
      final url = Uri.parse('$baseUrl/user/progress/week');
      print("📆 [WEEK PROGRESS]: GET $url");

      final response = await http
          .get(url, headers: _authHeaders(token))
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final raw = jsonDecode(response.body);
        // Expect either a List or {"days": [...]}
        final List rawList = raw is List
            ? raw
            : (raw['days'] ?? raw['week'] ?? []) as List;

        return rawList.map<Map<String, dynamic>>((item) {
          final m = Map<String, dynamic>.from(item);
          final goalCalories = overrideCalories ?? (m['goal_calories'] ?? 2400).toDouble();
          final calories =
              (m['calories'] ?? m['total_calories'] ?? 0).toDouble();
          final logs = m['meals'] ?? m['logs'] ?? [];
          final hasData = (logs is List && logs.isNotEmpty) || calories > 0;
          final progress =
              goalCalories > 0 ? calories / goalCalories : 0.0;
          return {
            'date': m['date']?.toString() ?? '',
            'calories': calories,
            'protein': (m['protein'] ?? 0).toDouble(),
            'carbs': (m['carbs'] ?? 0).toDouble(),
            'fats': (m['fats'] ?? 0).toDouble(),
            'goal_calories': goalCalories,
            'progress': progress,
            'has_data': hasData,
            'meals': logs,
            'grouped': m['grouped'] ?? {},
          };
        }).toList();
      }
    } catch (_) {
      // Fall through to composed approach
    }

    // ── Fallback: parallel per-day calls ─────────────────────────────
    print("📆 [WEEK PROGRESS]: Falling back to per-day calls");

    final now = DateTime.now();
    // Build 8-day range matching the UI bar (7 days ago → today)
    final dates = List.generate(
      8,
      (i) => now.subtract(Duration(days: 7 - i)),
    );

    final futures = dates.map((d) {
      final dateStr = "${d.year.toString().padLeft(4, '0')}-"
          "${d.month.toString().padLeft(2, '0')}-"
          "${d.day.toString().padLeft(2, '0')}";
      return getDayProgress(dateStr).catchError((_) => {
            'date': dateStr,
            'calories': 0.0,
            'protein': 0.0,
            'carbs': 0.0,
            'fats': 0.0,
            'goal_calories': 2400.0,
            'progress': 0.0,
            'has_data': false,
            'meals': <dynamic>[],
            'logs': <dynamic>[],
            'grouped': <String, dynamic>{},
          });
    });

    return Future.wait(futures);
  }

  // ─── DAILY PROGRESS (computed from history + plan) ───────────────────

  /// Get daily progress: consumed totals vs goals for a given date.
  Future<Map<String, dynamic>> getDailyProgress({String? date}) async {
    final dateStr =
        date ?? DateTime.now().toIso8601String().substring(0, 10);

    final results = await Future.wait([
      getFoodHistory(date: dateStr).catchError((_) => <String, dynamic>{}),
      getCaloriePlan().catchError((_) => <String, dynamic>{}),
    ]);

    final history = results[0] as Map<String, dynamic>;
    final plan = results[1] as Map<String, dynamic>;
    final totals = history['totals'] is Map
        ? Map<String, dynamic>.from(history['totals'])
        : <String, dynamic>{};

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

    double avgDeviation = 0;
    int count = 0;
    for (final ratio in [calRatio, protRatio, carbRatio, fatRatio]) {
      if (ratio > 0) {
        avgDeviation += (1.0 - ratio).abs();
        count++;
      }
    }
    avgDeviation = count > 0 ? avgDeviation / count : 1.0;

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
      // uncapped so the caller can show >100%
      'progress': goalCalories > 0 ? consumed / goalCalories : 0.0,
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
              final totals = data['totals'] is Map
                  ? Map<String, dynamic>.from(data['totals'])
                  : <String, dynamic>{};
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
  Future<Map<String, dynamic>> getStreak() async {
    final token = await _getToken();
    if (token == null) throw Exception("Not authenticated");

    final now = DateTime.now();
    final Set<String> loggedDates = {};

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

    int currentStreak = 0;
    for (int i = 0; i < 365; i++) {
      final date = now.subtract(Duration(days: i));
      final dateStr = date.toIso8601String().substring(0, 10);
      if (loggedDates.contains(dateStr)) {
        currentStreak++;
      } else if (i > 0) {
        break;
      }
    }

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

  Future<List<Map<String, dynamic>>> getBadges() async {
    final streak =
        await getStreak().catchError((_) => <String, dynamic>{});
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