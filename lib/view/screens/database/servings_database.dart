import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:graduation_project/services/api_service.dart';
import 'package:graduation_project/services/food_service.dart';
import 'package:go_router/go_router.dart';
 
class ServingsDatabase extends StatefulWidget {
  final String source;
  final String? barcode;
  final String? fdcId;
  final String? scanId;
  final String? logId;
  final String? mealType;
  final String? imageUrl;
  final Map<String, dynamic>? item;
 
  const ServingsDatabase({
    super.key,
    required this.source,
    this.barcode,
    this.fdcId,
    this.scanId,
    this.logId,
    this.mealType,
    this.imageUrl,
    this.item,
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
 
  // Helper to resolve images properly
  String? _getResolvedImageUrl(String? rawUrl) {
    if (rawUrl == null || rawUrl.toString().trim().isEmpty || rawUrl.toString().trim() == 'null') return null;

    final urlStr = rawUrl.toString().trim();
    if (urlStr.startsWith('http')) return urlStr;

    if (urlStr.contains('\\') || urlStr.contains('/')) {
      final filename = urlStr.split('/').last.split('\\').last;
      return '${ApiService.baseUrl}/user/food/scans/image/$filename';
    }

    final base = ApiService.baseUrl.endsWith('/')
        ? ApiService.baseUrl
        : '${ApiService.baseUrl}/';
    final path = urlStr.startsWith('/') ? urlStr.substring(1) : urlStr;
    return '$base$path';
  }
 
  // ── Used to call the log endpoint ──
  final FoodService _foodService = FoodService();
  bool _isLogging = false;
 
  @override
  void initState() {
    super.initState();
    _fetchFoodDetails();
  }
 
  @override
  void dispose() {
    super.dispose();
  }
 
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }
 
  void _usePassedItemData() {
    setState(() {
      foodData = widget.item;
      servings = [
        {
          "serving_name": widget.item!['serving_name'] ?? widget.item!['serving_size'] ?? '1 serving',
          "grams": double.tryParse(widget.item!['serving_size']?.toString().replaceAll(RegExp(r'[^0-9.]'), '') ?? '100') ?? 100.0,
          "calories": widget.item!['calories'] ?? 0.0,
          "protein": widget.item!['protein'] ?? 0.0,
          "carbs": widget.item!['carbs'] ?? 0.0,
          "fats": widget.item!['fats'] ?? widget.item!['fat'] ?? 0.0,
        }
      ];
      nutritionFacts = {
        "calories": widget.item!['calories'] ?? 0.0,
        "protein": widget.item!['protein'] ?? 0.0,
        "carbs": widget.item!['carbs'] ?? 0.0,
        "fats": widget.item!['fats'] ?? widget.item!['fat'] ?? 0.0,
        "fiber": widget.item!['fiber'] ?? 0.0,
        "sugar": widget.item!['sugar'] ?? 0.0,
        "calcium": widget.item!['calcium'] ?? 0.0,
        "sodium": widget.item!['sodium'] ?? 0.0,
      };
      selectedServing = servings[0];
      isLoading = false;
    });
  }
 
  Future<void> _fetchFoodDetails() async {
    print("🔍 [SERVING] Starting fetch | source=${widget.source} "
        "fdcId=${widget.fdcId} barcode=${widget.barcode} "
        "scanId=${widget.scanId} logId=${widget.logId}");
  
    if (widget.fdcId == null &&
        widget.barcode == null &&
        widget.scanId == null &&
        widget.logId == null &&
        widget.item != null) {
      print("🔍 [SERVING] No remote ID provided. Using passed item data.");
      _usePassedItemData();
      return;
    }
  
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
        final data = Map<String, dynamic>.from(json.decode(response.body));
  
        final nf = data['nutrition_facts'] is Map ? Map<String, dynamic>.from(data['nutrition_facts']) : null;
        final ld = data['log_details'] is Map ? Map<String, dynamic>.from(data['log_details']) : null;
  
        print("🔍 [SERVING] nutrition_facts keys = ${nf?.keys.toList()}");
        print("🔍 [SERVING] nutrition_facts full = $nf");
  
        setState(() {
          foodData       = data['food'] is Map ? Map<String, dynamic>.from(data['food']) : null;
          servings       = (data['servings'] as List?) ?? [];
          nutritionFacts = nf;
          logDetails     = ld;
          if (servings.isNotEmpty) {
            selectedServing = Map<String, dynamic>.from(servings[0] as Map);
          }
          isLoading = false;
        });
      } else {
        if (widget.barcode != null && widget.barcode!.isNotEmpty) {
          await _fetchFromOpenFoodFactsDirectly(widget.barcode!);
          return;
        }
        if (widget.item != null) {
          print("🔍 [SERVING] Remote returned error, using local fallback");
          _usePassedItemData();
          return;
        }
        final body = json.decode(response.body) as Map<String, dynamic>;
        setState(() {
          errorMessage = body['message'] ?? body['error'] ?? "Failed to load food details";
          isLoading = false;
        });
      }
    } catch (e, stack) {
      print("🔍 [SERVING] EXCEPTION: $e\n$stack");
      if (widget.barcode != null && widget.barcode!.isNotEmpty) {
        try {
          await _fetchFromOpenFoodFactsDirectly(widget.barcode!);
          return;
        } catch (fallbackError) {
          print("🔍 [SERVING] Fallback exception: $fallbackError");
        }
      }
      if (widget.item != null) {
        print("🔍 [SERVING] Request exception, using local fallback");
        _usePassedItemData();
        return;
      }
      setState(() {
        errorMessage = "An error occurred: $e";
        isLoading = false;
      });
    }
  }

  Future<void> _fetchFromOpenFoodFactsDirectly(String barcode) async {
    print("🔍 [SERVING] Querying Open Food Facts directly for barcode: $barcode");
    try {
      final response = await http.get(
        Uri.parse("https://world.openfoodfacts.org/api/v2/product/$barcode"),
        headers: {
          "User-Agent": "GraduationProject/1.0 (Flutter App)",
        },
      ).timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 1 && data['product'] != null) {
          final product = data['product'];
          final String name = product['product_name'] ?? product['product_name_en'] ?? 'Unknown Barcode Product';
          final String img = product['image_url'] ?? product['image_front_url'] ?? '';

          final nutriments = product['nutriments'] ?? {};
          final double calories100g = double.tryParse(nutriments['energy-kcal_100g']?.toString() ?? '')
              ?? double.tryParse(nutriments['energy-kcal']?.toString() ?? '')
              ?? 0.0;
          final double protein100g = double.tryParse(nutriments['proteins_100g']?.toString() ?? '')
              ?? double.tryParse(nutriments['proteins']?.toString() ?? '')
              ?? 0.0;
          final double carbs100g = double.tryParse(nutriments['carbohydrates_100g']?.toString() ?? '')
              ?? double.tryParse(nutriments['carbohydrates']?.toString() ?? '')
              ?? 0.0;
          final double fat100g = double.tryParse(nutriments['fat_100g']?.toString() ?? '')
              ?? double.tryParse(nutriments['fat']?.toString() ?? '')
              ?? 0.0;
          final double fiber100g = double.tryParse(nutriments['fiber_100g']?.toString() ?? '')
              ?? double.tryParse(nutriments['fiber']?.toString() ?? '')
              ?? 0.0;
          final double sugar100g = double.tryParse(nutriments['sugars_100g']?.toString() ?? '')
              ?? double.tryParse(nutriments['sugars']?.toString() ?? '')
              ?? 0.0;
          
          // sodium in OFF is in grams per 100g, convert to mg per 100g
          final double sodium100g = (double.tryParse(nutriments['sodium_100g']?.toString() ?? '')
              ?? double.tryParse(nutriments['sodium']?.toString() ?? '')
              ?? 0.0) * 1000.0;
          
          // calcium in OFF is in grams/100g, convert to mg per 100g
          final double calcium100g = (double.tryParse(nutriments['calcium_100g']?.toString() ?? '')
              ?? double.tryParse(nutriments['calcium']?.toString() ?? '')
              ?? 0.0) * 1000.0;

          final String servingSizeStr = product['serving_size']?.toString() ?? '';
          double servingGrams = 100.0;
          if (servingSizeStr.isNotEmpty) {
            final sq = double.tryParse(product['serving_quantity']?.toString() ?? '');
            if (sq != null && sq > 0) {
              servingGrams = sq;
            } else {
              final match = RegExp(r'([0-9.]+)\s*(g|ml|G|ML)').firstMatch(servingSizeStr);
              if (match != null) {
                servingGrams = double.tryParse(match.group(1) ?? '') ?? 100.0;
              }
            }
          }

          final double factor = servingGrams / 100.0;
          final double servingCalories = calories100g * factor;
          final double servingProtein = protein100g * factor;
          final double servingCarbs = carbs100g * factor;
          final double servingFats = fat100g * factor;

          final Map<String, dynamic> localFoodData = {
            "food_name": name,
            "image_url": img,
          };

          final List<Map<String, dynamic>> localServings = [
            if (servingSizeStr.isNotEmpty)
              {
                "serving_name": "Serving ($servingSizeStr)",
                "grams": servingGrams,
                "calories": servingCalories,
                "protein": servingProtein,
                "carbs": servingCarbs,
                "fats": servingFats,
              },
            {
              "serving_name": "100g",
              "grams": 100.0,
              "calories": calories100g,
              "protein": protein100g,
              "carbs": carbs100g,
              "fats": fat100g,
            }
          ];

          final Map<String, dynamic> localNutritionFacts = {
            "calories": calories100g,
            "protein": protein100g,
            "carbs": carbs100g,
            "fats": fat100g,
            "fiber": fiber100g,
            "sugar": sugar100g,
            "calcium": calcium100g,
            "sodium": sodium100g,
            "health_score": 0,
            "health_tip": "",
            "glycemic_index_rating": "",
            "gl_category": "",
          };

          setState(() {
            foodData = localFoodData;
            servings = localServings;
            nutritionFacts = localNutritionFacts;
            selectedServing = localServings[0];
            isLoading = false;
            errorMessage = null;
          });
          return;
        }
      }
      throw Exception("Product status is not active on Open Food Facts");
    } catch (e) {
      print("🔍 [SERVING] OFF Fallback error: $e");
      setState(() {
        errorMessage = "Product not found in database or Open Food Facts";
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
 
  /// Shows a meal-type picker (if mealType not provided via widget), then calls the log endpoint.
  Future<void> _onAddFood() async {
    final mealType = widget.mealType ?? await _showMealTypePicker();
    if (mealType == null) return;
 
    setState(() => _isLogging = true);
 
    try {
      final String foodName =
          foodData?['food_name'] ?? foodData?['meal_name'] ?? 'Unknown Food';
 
      final num calories =
          selectedServing?['calories']
          ?? nutritionFacts?['calories']
          ?? foodData?['calories']
          ?? foodData?['base_calories']
          ?? 0;
      final num protein =
          selectedServing?['protein']
          ?? _nf(['protein', 'protein_g'])
          ?? foodData?['protein']
          ?? foodData?['base_protein']
          ?? 0;
      final num carbs =
          selectedServing?['carbs']
          ?? _nf(['carbs', 'carbs_g', 'carbohydrates'])
          ?? foodData?['carbs']
          ?? foodData?['base_carbs']
          ?? 0;
      final num fats =
          selectedServing?['fats']
          ?? _nf(['fats', 'fat', 'fat_g'])
          ?? foodData?['fats']
          ?? foodData?['fat']
          ?? foodData?['base_fats']
          ?? 0;
 
      final double scaledCalories = calories.toDouble() * servingCount;
      final double scaledProtein  = protein.toDouble()  * servingCount;
      final double scaledCarbs    = carbs.toDouble()    * servingCount;
      final double scaledFats     = fats.toDouble()     * servingCount;
 
      final double baseCalories = calories.toDouble();
      final double baseProtein  = protein.toDouble();
      final double baseCarbs    = carbs.toDouble();
      final double baseFats     = fats.toDouble();
 
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
        'base_calories': baseCalories,
        'base_protein':  baseProtein,
        'base_carbs':    baseCarbs,
        'base_fats':     baseFats,
        'portion_multiplier': servingCount.toDouble(),
        'serving_name': servingName,
        'serving_size': (servingWeight is num)
            ? servingWeight.toDouble() * servingCount
            : servingCount.toDouble(),
        'meal_type':    mealType,
        'image_url':    foodData?['image_path'] ?? foodData?['image_url'] ?? widget.imageUrl,
        if (widget.scanId != null) 'scan_id': widget.scanId,
        'ai_scan': widget.source == 'saved_scans',
        'log_time': DateTime.now().toIso8601String(),
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
    final String? resolvedImg = _getResolvedImageUrl(foodData?['image_path'] ?? foodData?['image_url'] ?? widget.imageUrl);
    final String imageUrl = resolvedImg ?? '';

    final num    calories  = selectedServing?['calories']
                              ?? nutritionFacts?['calories']
                              ?? foodData?['calories']
                              ?? foodData?['base_calories']
                              ?? 0;
    final double scaledCal = calories.toDouble() * servingCount;
 
    final String servingLabel  = selectedServing?['serving_name'] ?? "100g";
    final String servingWeight =
        (selectedServing?['serving_weight_grams'] ?? selectedServing?['grams'])
            ?.toString() ?? "100";
 
    final String protein = _fmt(
        selectedServing?['protein']
        ?? _nf(['protein', 'protein_g'])
        ?? foodData?['protein']
        ?? foodData?['base_protein']
        ?? 0.0
    );
    final String carbs = _fmt(
        selectedServing?['carbs']
        ?? _nf(['carbs', 'carbs_g', 'carbohydrates'])
        ?? foodData?['carbs']
        ?? foodData?['base_carbs']
        ?? 0.0
    );
    final String fats = _fmt(
        selectedServing?['fats']
        ?? _nf(['fats', 'fat', 'fat_g'])
        ?? foodData?['fats']
        ?? foodData?['fat']
        ?? foodData?['base_fats']
        ?? 0.0
    );
 
    final double fallbackFiber = double.tryParse(foodData?['fiber']?.toString() ?? '0') ?? 0.0;
    final double fallbackSugar = double.tryParse(foodData?['sugar']?.toString() ?? '0') ?? 0.0;
    final double fallbackCalcium = double.tryParse(foodData?['calcium']?.toString() ?? '0') ?? 0.0;
    final double fallbackSodium = double.tryParse(foodData?['sodium']?.toString() ?? '0') ?? 0.0;

    final String fiber   = _fmtNf(['fiber',   'fiber_g'], fallback: fallbackFiber);
    final String sugar   = _fmtNf(['sugar',   'sugar_g'], fallback: fallbackSugar);
    final String calcium = _fmtNf(['calcium', 'calcium_mg'], decimals: 0, fallback: fallbackCalcium);
    final String sodium  = _fmtNf(['sodium',  'sodium_mg'],  decimals: 0, fallback: fallbackSodium);
 
    final String mealType = logDetails?['meal_type'] ?? '';
    final String logTime  = logDetails?['log_time']  ?? '';
 
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
        child: ListView(
          padding: EdgeInsets.fromLTRB(sw * 0.05, 10, sw * 0.05, 20),
          children: [
            Row(
              children: [
                IconButton(
                  onPressed: () => context.pop(),
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

            // Header
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: const Color(0xffE8F5E9),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: imageUrl.isNotEmpty
                        ? Image.network(
                            imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Center(
                              child: Text(_getFoodEmoji(foodName),
                                  style: const TextStyle(fontSize: 28)),
                            ),
                          )
                        : Center(
                            child: Text(_getFoodEmoji(foodName),
                                style: const TextStyle(fontSize: 28)),
                          ),
                  ),
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

            // Serving Size
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
                                  color: Colors.black)),
                          TextSpan(
                              text: "($servingCount×${servingWeight}g)",
                              style: const TextStyle(
                                  fontSize: 12,
                                  color: Color(0xffA3A3A3))),
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

            // Macronutrients
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

                  _nutritionRow("Fiber",   "$fiber g"),
                  _divider(),
                  _nutritionRow("Sugar",   "$sugar g"),
                  _divider(),
                  _nutritionRow("Calcium", "$calcium mg"),
                  _divider(),
                  _nutritionRow("Sodium",  "$sodium mg"),

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

            // Log Details
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

            const SizedBox(height: 32),

            // "Add food" button — inline at the bottom
            SizedBox(
              height: 52,
              width: double.infinity,
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
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
 
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
            shape: BoxShape.circle,
            color: filled ? Colors.black : Colors.white,
            border: Border.all(color: Colors.black, width: 1.5),
          ),
          child: Icon(icon,
              color: filled ? Colors.white : Colors.black, size: 18),
        ),
      );

  String _getFoodEmoji(String name) {
    final n = name.toLowerCase();
    if (n.contains('salad')) return '🥗';
    if (n.contains('pizza')) return '🍕';
    if (n.contains('burger')) return '🍔';
    if (n.contains('pasta') || n.contains('noodle') || n.contains('spaghetti')) return '🍝';
    if (n.contains('rice')) return '🍚';
    if (n.contains('soup') || n.contains('stew')) return '🥣';
    return '🍽️';
  }
}