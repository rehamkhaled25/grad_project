import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:graduation_project/services/api_service.dart';
import 'package:graduation_project/services/food_service.dart';
 
class ServingsDatabase extends StatefulWidget {
  final String source;
  final String? barcode;
  final String? fdcId;
  final String? scanId;
  final String? logId;
 
  const ServingsDatabase({
    super.key,
    required this.source,
    this.barcode,
    this.fdcId,
    this.scanId,
    this.logId,
  });
 
  @override
  State<ServingsDatabase> createState() => _ServingsDatabaseState();
}
 
class _ServingsDatabaseState extends State<ServingsDatabase> {
  Map<String, dynamic>? foodData;
  List<dynamic> servings = [];
  Map<String, dynamic>? nutritionFacts;
  Map<String, dynamic>? selectedServing;
  Map<String, dynamic>? logDetails;
  bool isLoading = true;
  String? errorMessage;
  int servingCount = 1;
 
  // ── Used to show "Add food" button only when the user scrolls down ──
  final ScrollController _scrollController = ScrollController();
  bool _showAddButton = false;
 
  // ── Used to call the log endpoint ──
  final FoodService _foodService = FoodService();
  bool _isLogging = false;
 
  @override
  void initState() {
    super.initState();
    _fetchFoodDetails();
 
    // Listen to scroll position: show button after user scrolls 80px
    _scrollController.addListener(() {
      final shouldShow = _scrollController.offset > 80;
      if (shouldShow != _showAddButton) {
        setState(() => _showAddButton = shouldShow);
      }
    });
  }
 
  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
 
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }
 
  Future<void> _fetchFoodDetails() async {
    print("🔍 [SERVING] Starting fetch | source=${widget.source} "
        "fdcId=${widget.fdcId} barcode=${widget.barcode} "
        "scanId=${widget.scanId} logId=${widget.logId}");
 
    setState(() {
      isLoading = true;
      errorMessage = null;
    });
 
    try {
      final token = await _getToken();
      if (token == null) throw Exception("Not authenticated");
 
      final String baseUrl = ApiService.baseUrl;
 
      final queryParameters = <String, String>{
        'source': widget.source,
        if (widget.barcode != null) 'barcode': widget.barcode!,
        if (widget.fdcId != null) 'fdc_id': widget.fdcId!,
        if (widget.scanId != null) 'scan_id': widget.scanId!,
        if (widget.logId != null) 'log_id': widget.logId!,
      };
 
      final uri = Uri.parse("$baseUrl/user/food/database/serving")
          .replace(queryParameters: queryParameters);
 
      print("🔍 [SERVING] URL = $uri");
 
      final response = await http.get(uri, headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      }).timeout(const Duration(seconds: 10));
 
      print("🔍 [SERVING] HTTP status = ${response.statusCode}");
 
      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
 
        final nf = data['nutrition_facts'] as Map<String, dynamic>?;
        final ld = data['log_details'] as Map<String, dynamic>?;
 
        print("🔍 [SERVING] nutrition_facts keys = ${nf?.keys.toList()}");
        print("🔍 [SERVING] nutrition_facts full = $nf");
 
        setState(() {
          foodData       = data['food'] as Map<String, dynamic>?;
          servings       = (data['servings'] as List?) ?? [];
          nutritionFacts = nf;
          logDetails     = ld;
          if (servings.isNotEmpty) {
            selectedServing = servings[0] as Map<String, dynamic>;
          }
          isLoading = false;
        });
      } else {
        final body = json.decode(response.body) as Map<String, dynamic>;
        setState(() {
          errorMessage = body['message'] ?? body['error'] ?? "Failed to load food details";
          isLoading = false;
        });
      }
    } catch (e, stack) {
      print("🔍 [SERVING] EXCEPTION: $e\n$stack");
      setState(() {
        errorMessage = "An error occurred: $e";
        isLoading = false;
      });
    }
  }
 
  // ── Helpers ───────────────────────────────────────────────────────────────
 
  /// Safely read a number from nutrition_facts, trying multiple possible key names.
  double _nf(List<String> keys, {double fallback = 0.0}) {
    if (nutritionFacts == null) return fallback;
    for (final k in keys) {
      final v = nutritionFacts![k];
      if (v != null) return double.tryParse(v.toString()) ?? fallback;
    }
    return fallback;
  }
 
  double _scaledValue(dynamic raw) {
    final base = double.tryParse(raw?.toString() ?? '0') ?? 0;
    return base * servingCount;
  }
 
  String _fmt(dynamic raw, {int decimals = 1}) =>
      _scaledValue(raw).toStringAsFixed(decimals);
 
  String _fmtNf(List<String> keys, {int decimals = 1, double fallback = 0.0}) =>
      (_nf(keys, fallback: fallback) * servingCount).toStringAsFixed(decimals);
 
  // ── Add Food Logic ────────────────────────────────────────────────────────
 
  /// Shows a meal-type picker, then calls the log endpoint.
  Future<void> _onAddFood() async {
    // Step 1: ask which meal type
    final mealType = await _showMealTypePicker();
    if (mealType == null) return; // user dismissed
 
    setState(() => _isLogging = true);
 
    try {
      final String foodName =
          foodData?['food_name'] ?? foodData?['meal_name'] ?? 'Unknown Food';
 
      final num calories =
          selectedServing?['calories'] ?? nutritionFacts?['calories'] ?? 0;
      final num protein =
          selectedServing?['protein'] ?? _nf(['protein', 'protein_g']);
      final num carbs =
          selectedServing?['carbs'] ?? _nf(['carbs', 'carbs_g', 'carbohydrates']);
      final num fats =
          selectedServing?['fats'] ?? _nf(['fats', 'fat', 'fat_g']);
 
      final double scaledCalories = calories.toDouble() * servingCount;
      final double scaledProtein  = protein.toDouble()  * servingCount;
      final double scaledCarbs    = carbs.toDouble()    * servingCount;
      final double scaledFats     = fats.toDouble()     * servingCount;
 
      final String servingName =
          selectedServing?['serving_name'] ?? '1 serving';
      final dynamic servingWeight =
          selectedServing?['serving_weight_grams'] ??
          selectedServing?['grams'] ??
          100;
 
      // Build the payload for POST /user/food/log
      final Map<String, dynamic> payload = {
        'food_name':    foodName,
        'calories':     scaledCalories,
        'protein':      scaledProtein,
        'carbs':        scaledCarbs,
        'fats':         scaledFats,
        'serving_name': servingName,
        'serving_size': (servingWeight is num)
            ? servingWeight.toDouble() * servingCount
            : servingCount.toDouble(),
        'meal_type':    mealType,
        // Pass scan_id if this food came from a scan so it's saved under saved_scans
        if (widget.scanId != null) 'scan_id': widget.scanId,
        // ai_scan = true when source is saved_scans (it was AI-analyzed)
        'ai_scan': widget.source == 'saved_scans',
      };
 
      await _foodService.logFood(payload);
 
      if (!mounted) return;
 
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("✅ Food added successfully!"),
          backgroundColor: Colors.black,
          duration: Duration(seconds: 2),
        ),
      );
 
      // Pop back to the database search screen
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("❌ Failed to log food: $e"),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLogging = false);
    }
  }
 
  /// Returns the selected meal type string, or null if dismissed.
  Future<String?> _showMealTypePicker() {
    return showModalBottomSheet<String>(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) {
        final options = [
          ('Breakfast', 'breakfast', Icons.wb_sunny_outlined),
          ('Lunch',     'lunch',     Icons.lunch_dining_outlined),
          ('Dinner',    'dinner',    Icons.nights_stay_outlined),
          ('Snack',     'snack',     Icons.cookie_outlined),
        ];
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Add to which meal?",
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              ...options.map((opt) => ListTile(
                    leading: Icon(opt.$3, color: Colors.black),
                    title: Text(opt.$1,
                        style: const TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w500)),
                    onTap: () => Navigator.pop(context, opt.$2),
                  )),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }
 
  // ── Build ──────────────────────────────────────────────────────────────────
 
  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
          body: Center(child: CircularProgressIndicator(color: Colors.black)));
    }
 
    if (errorMessage != null) {
      return Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.red, fontSize: 15)),
          ),
        ),
      );
    }
 
    final double sw = MediaQuery.of(context).size.width;
 
    final String foodName  = foodData?['food_name'] ?? foodData?['meal_name'] ?? "Unknown Food";
    final String imageUrl  = foodData?['image_path'] ?? foodData?['image_url'] ?? '';
    final num    calories  = selectedServing?['calories']
                              ?? nutritionFacts?['calories']
                              ?? 0;
    final double scaledCal = calories.toDouble() * servingCount;
 
    final String servingLabel  = selectedServing?['serving_name'] ?? "100g";
    final String servingWeight =
        (selectedServing?['serving_weight_grams'] ?? selectedServing?['grams'])
            ?.toString() ?? "100";
 
    // ── Macros: from selectedServing first, fall back to nutrition_facts ──────
    final String protein = _fmt(
        selectedServing?['protein'] ?? _nf(['protein', 'protein_g']));
    final String carbs = _fmt(
        selectedServing?['carbs'] ?? _nf(['carbs', 'carbs_g', 'carbohydrates']));
    final String fats = _fmt(
        selectedServing?['fats'] ?? _nf(['fats', 'fat', 'fat_g']));
 
    // ── Nutrition facts ───────────────────────────────────────────────────────
    // Backend returns for USDA:           fiber, sugar, sodium         (no suffix)
    // Backend returns for Open Food Facts: fiber, sugar, sodium        (no suffix)
    // Backend returns for saved_scans:    full_report (fiber_g, calcium_mg, etc.)
    // We try all known key variants so it works regardless of source.
    final String fiber   = _fmtNf(['fiber',   'fiber_g']);
    final String sugar   = _fmtNf(['sugar',   'sugar_g']);
    final String calcium = _fmtNf(['calcium', 'calcium_mg'], decimals: 0);
    final String sodium  = _fmtNf(['sodium',  'sodium_mg'],  decimals: 0);
 
    // ── Log details ───────────────────────────────────────────────────────────
    final String mealType = logDetails?['meal_type'] ?? '';
    final String logTime  = logDetails?['log_time']  ?? '';
 
    // ── Health info from backend ──────────────────────────────────────────────
    final int    healthScore = int.tryParse(
            nutritionFacts?['health_score']?.toString() ?? '0') ?? 0;
    final String healthTip   = nutritionFacts?['health_tip']?.toString() ?? '';
    final String giRating    =
        nutritionFacts?['glycemic_index_rating']?.toString() ?? '';
    final String glCategory  =
        nutritionFacts?['gl_category']?.toString() ?? '';
 
    final bool hasHealthInfo =
        healthScore > 0 || healthTip.isNotEmpty || giRating.isNotEmpty;
 
    return Scaffold(
      backgroundColor: const Color(0xffF4F4F4),
      body: SafeArea(
        child: Stack(
          children: [
            // ── Full scrollable content ─────────────────────────────────────
            ListView(
              controller: _scrollController,
              padding: EdgeInsets.fromLTRB(sw * 0.05, 10, sw * 0.05, 100),
              children: [
                // Back row
                Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back,
                          size: 24, color: Color(0xff151316)),
                    ),
                    const Text("Back to database",
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black)),
                  ],
                ),
                const SizedBox(height: 20),
 
                // ── Food header ───────────────────────────────────────────
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: const Color(0xffE8F5E9),
                        image: imageUrl.isNotEmpty
                            ? DecorationImage(
                                image: NetworkImage(
                                  imageUrl.startsWith('http')
                                      ? imageUrl
                                      : '${ApiService.baseUrl}$imageUrl',
                                ),
                                fit: BoxFit.cover,
                                onError: (_, __) {},
                              )
                            : null,
                      ),
                      child: imageUrl.isEmpty
                          ? const Center(
                              child: Text("🍜",
                                  style: TextStyle(fontSize: 28)))
                          : null,
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(foodName,
                              style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black)),
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xffEEEEEE),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              "${scaledCal.toStringAsFixed(0)} calories",
                              style: const TextStyle(
                                  fontSize: 13,
                                  color: Colors.black87,
                                  fontWeight: FontWeight.w500),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
 
                // ── Serving size card ─────────────────────────────────────
                _card(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          RichText(
                            text: TextSpan(children: [
                              const TextSpan(
                                text: "Serving Size ",
                                style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black),
                              ),
                              TextSpan(
                                text: "($servingCount×${servingWeight}g)",
                                style: const TextStyle(
                                    fontSize: 12,
                                    color: Color(0xffA3A3A3)),
                              ),
                            ]),
                          ),
                          Row(
                            children: [
                              _controlBtn(Icons.remove, false, () {
                                if (servingCount > 1) {
                                  setState(() => servingCount--);
                                }
                              }),
                              const SizedBox(width: 8),
                              _controlBtn(Icons.add, true, () {
                                setState(() => servingCount++);
                              }),
                            ],
                          ),
                        ],
                      ),
                      // Only show the serving dropdown if there are multiple servings
                      if (servings.length > 1) ...[
                        const SizedBox(height: 8),
                        GestureDetector(
                          onTap: () => _showServingPicker(context),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(servingLabel,
                                  style: const TextStyle(
                                      fontSize: 14,
                                      color: Color(0xff555555))),
                              const Icon(Icons.keyboard_arrow_down,
                                  color: Color(0xffBBBABA)),
                            ],
                          ),
                        ),
                      ] else ...[
                        const SizedBox(height: 8),
                        Text(servingLabel,
                            style: const TextStyle(
                                fontSize: 14,
                                color: Color(0xff555555))),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 16),
 
                // ── Macros + Nutrition facts card ─────────────────────────
                _card(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Macronutrients",
                          style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Colors.black)),
                      const SizedBox(height: 12),
                      _nutritionRow("Protein", "$protein g"),
                      _divider(),
                      _nutritionRow("Carbs", "$carbs g"),
                      _divider(),
                      _nutritionRow("Fats", "$fats g"),
                      const SizedBox(height: 20),
 
                      const Text("Nutrition Facts",
                          style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Colors.black)),
                      const SizedBox(height: 12),
 
                      // Fiber — returned by USDA, Open Food Facts, and saved_scans
                      _nutritionRow("Fiber",   "$fiber g"),
                      _divider(),
                      // Sugar — returned by USDA, Open Food Facts, and saved_scans
                      _nutritionRow("Sugar",   "$sugar g"),
                      _divider(),
                      // Calcium — returned by saved_scans (AI report); may be 0 for USDA/OFF
                      _nutritionRow("Calcium", "$calcium mg"),
                      _divider(),
                      // Sodium — returned by USDA, Open Food Facts, and saved_scans
                      _nutritionRow("Sodium",  "$sodium mg"),
 
                      // "View full nutrition" button — only shows if AI health info exists
                      if (hasHealthInfo) ...[
                        const SizedBox(height: 16),
                        GestureDetector(
                          onTap: () => _showHealthTip(
                              context, healthTip, healthScore, giRating, glCategory),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              color: const Color(0xffF4F4F4),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Center(
                              child: Text(
                                "View full nutrition info →",
                                style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.black54,
                                    fontWeight: FontWeight.w600),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 16),
 
                // ── Log Details card (only if log details exist) ──────────
                if (mealType.isNotEmpty || logTime.isNotEmpty)
                  _card(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Log Details",
                            style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Colors.black)),
                        const SizedBox(height: 12),
                        if (logTime.isNotEmpty) ...[
                          _logDetailRow("Log time", logTime),
                          _divider(),
                        ],
                        if (mealType.isNotEmpty)
                          _logDetailRow("Meal", mealType),
                      ],
                    ),
                  ),
 
                const SizedBox(height: 24),
              ],
            ),
 
            // ── "Add food" button — appears only after scrolling down ───────
            AnimatedPositioned(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOut,
              bottom: _showAddButton ? 16 : -80,
              left: sw * 0.05,
              right: sw * 0.05,
              child: SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: _isLogging ? null : _onAddFood,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: Colors.black54,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                    elevation: 4,
                  ),
                  child: _isLogging
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2.5),
                        )
                      : const Text("Add food",
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
 
  // ── Full nutrition / health tip bottom sheet ───────────────────────────────
 
  void _showHealthTip(BuildContext context, String tip, int score,
      String giRating, String glCategory) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.5,
        maxChildSize: 0.85,
        builder: (_, ctrl) => ListView(
          controller: ctrl,
          padding: const EdgeInsets.all(24),
          children: [
            const Text("Full Nutrition Info",
                style:
                    TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            if (score > 0) ...[
              _sheetRow("Health Score", "$score / 10"),
              const Divider(),
            ],
            if (giRating.isNotEmpty) ...[
              _sheetRow("Glycemic Index", giRating),
              const Divider(),
            ],
            if (glCategory.isNotEmpty) ...[
              _sheetRow("GL Category", glCategory),
              const Divider(),
            ],
            if (tip.isNotEmpty) ...[
              const SizedBox(height: 8),
              const Text("Health Tip",
                  style: TextStyle(
                      fontSize: 14, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(tip,
                  style: const TextStyle(
                      fontSize: 13, color: Color(0xff555555))),
            ],
          ],
        ),
      ),
    );
  }
 
  Widget _sheetRow(String label, String value) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label,
                style: const TextStyle(
                    fontSize: 14, color: Color(0xff444444))),
            Text(value,
                style: const TextStyle(
                    fontSize: 14, fontWeight: FontWeight.w600)),
          ],
        ),
      );
 
  // ── Serving picker ─────────────────────────────────────────────────────────
 
  void _showServingPicker(BuildContext context) {
    if (servings.isEmpty) return;
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => ListView.separated(
        shrinkWrap: true,
        padding: const EdgeInsets.symmetric(vertical: 16),
        itemCount: servings.length,
        separatorBuilder: (_, __) =>
            const Divider(height: 0, color: Color(0xffEEEEEE)),
        itemBuilder: (_, i) {
          final s = servings[i] as Map<String, dynamic>;
          final isSelected = s == selectedServing;
          return ListTile(
            title: Text(s['serving_name'] ?? '',
                style: TextStyle(
                    fontWeight: isSelected
                        ? FontWeight.bold
                        : FontWeight.normal)),
            trailing: isSelected
                ? const Icon(Icons.check, color: Colors.black)
                : null,
            onTap: () {
              setState(() => selectedServing = s);
              Navigator.pop(context);
            },
          );
        },
      ),
    );
  }
 
  // ── Widget helpers ─────────────────────────────────────────────────────────
 
  Widget _card({required Widget child}) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xffEEEEEE)),
        ),
        child: child,
      );
 
  Widget _divider() =>
      const Divider(height: 16, thickness: 0.8, color: Color(0xffEEEEEE));
 
  Widget _nutritionRow(String label, String value) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label,
                style: const TextStyle(
                    fontSize: 14, color: Color(0xff444444))),
            Text(value,
                style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.black)),
          ],
        ),
      );
 
  /// Log detail row — no arrow icon (it was useless and opened nothing).
  Widget _logDetailRow(String label, String value) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label,
                style: const TextStyle(
                    fontSize: 14, color: Color(0xff444444))),
            Text(value,
                style: const TextStyle(
                    fontSize: 14, color: Colors.black)),
          ],
        ),
      );
 
  Widget _controlBtn(IconData icon, bool filled, VoidCallback onTap) =>
      GestureDetector(
        onTap: onTap,
        child: Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: filled ? Colors.black : Colors.white,
            shape: BoxShape.circle,
            border: filled
                ? null
                : Border.all(color: const Color(0xffBBBABA)),
          ),
          child: Icon(icon,
              size: 18,
              color: filled ? Colors.white : Colors.black),
        ),
      );
}