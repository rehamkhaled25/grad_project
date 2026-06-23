// ─── FoodItem ─────────────────────────────────────────────────────────────────
// Represents a single food search result regardless of its source
// (usda_fdc, open_food_facts, my_meals, my_foods, saved_scans).

class FoodItem {
  final String name;
  final double calories;
  final double protein;
  final double carbs;
  final double fats;
  final String source;
  final String? imageUrl;
  final String? fdcId;
  final String? barcode;
  final String? scanId;
  final int? logId;
  final String? brand;
  final String? servingSize;

  const FoodItem({
    required this.name,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fats,
    this.source = 'all',
    this.imageUrl,
    this.fdcId,
    this.barcode,
    this.scanId,
    this.logId,
    this.brand,
    this.servingSize,
  });

  /// Build a FoodItem from the JSON map returned by the backend search endpoint.
  /// [tab] is the currently-selected tab so we can pick the right id field.
  factory FoodItem.fromJson(Map<String, dynamic> json, [String tab = 'all']) {
    return FoodItem(
      name: json['food_name']?.toString() ??
          json['meal_name']?.toString() ??
          'Unknown',
      calories:
          double.tryParse(json['calories']?.toString() ?? '0') ?? 0,
      protein:
          double.tryParse(json['protein']?.toString() ?? '0') ?? 0,
      carbs: double.tryParse(json['carbs']?.toString() ?? '0') ?? 0,
      fats: double.tryParse(json['fats']?.toString() ?? '0') ?? 0,
      source: json['source']?.toString() ?? tab,
      imageUrl: json['image_url']?.toString(),
      fdcId: json['fdc_id']?.toString(),
      barcode: json['barcode']?.toString(),
      scanId: json['scan_id']?.toString(),
      logId: int.tryParse(json['log_id']?.toString() ?? ''),
      brand: json['brand']?.toString(),
      servingSize: json['serving_size']?.toString(),
    );
  }
}

// ─── NutritionReport ──────────────────────────────────────────────────────────
// Represents the detailed AI-generated nutrition report for a scanned meal.

class HiddenIngredientReport {
  final String name;
  final double impactCalories;
  final double impactProtein;
  final double impactCarbs;
  final double impactFat;
  final String impactExplanation;
  final String generalInfo;

  HiddenIngredientReport({
    required this.name,
    required this.impactCalories,
    required this.impactProtein,
    required this.impactCarbs,
    required this.impactFat,
    required this.impactExplanation,
    required this.generalInfo,
  });

  factory HiddenIngredientReport.fromJson(Map<String, dynamic> json) {
    return HiddenIngredientReport(
      name: json['name']?.toString() ?? "",
      impactCalories: double.tryParse(json['impact_calories']?.toString() ?? "0") ?? 0.0,
      impactProtein: double.tryParse(json['impact_protein_g']?.toString() ?? "0") ?? 0.0,
      impactCarbs: double.tryParse(json['impact_carbs_g']?.toString() ?? "0") ?? 0.0,
      impactFat: double.tryParse(json['impact_fat_g']?.toString() ?? "0") ?? 0.0,
      impactExplanation: json['impact_explanation']?.toString() ?? "",
      generalInfo: json['general_info']?.toString() ?? "",
    );
  }
}

class NutritionReport {
  final String mealName;
  final double totalCalories;
  final double totalProtein;
  final double totalCarbs;
  final double totalFat;
  final double? sugar;
  final int? sodium;
  final int glycemicIndex;
  final int glycemicLoad;
  final int? magnesium;
  final int? calcium;
  final int? fiber;
  final String vitamins;
  final int healthScore;
  final String healthTip;
  final String warning;
  final List<HiddenIngredientReport> hiddenIngredients;

  NutritionReport({
    required this.mealName,
    required this.totalCalories,
    required this.totalProtein,
    required this.totalCarbs,
    required this.totalFat,
    this.sugar,
    this.sodium,
    required this.glycemicIndex,
    required this.glycemicLoad,
    this.magnesium,
    this.calcium,
    this.fiber,
    required this.vitamins,
    required this.healthScore,
    required this.healthTip,
    required this.warning,
    required this.hiddenIngredients,
  });

  /// Parses a nullable double from two candidate JSON keys.
  /// Returns null only when BOTH keys are absent/null in the source.
  /// Preserves explicit 0 from the API.
  static double? _tryParseNullableDouble(Map<String, dynamic> json, String key1, String key2) {
    final raw = json[key1] ?? json[key2];
    if (raw == null) return null;
    return double.tryParse(raw.toString()) ?? 0.0;
  }

  /// Same as above but returns int? (rounded).
  static int? _tryParseNullableInt(Map<String, dynamic> json, String key1, String key2) {
    final d = _tryParseNullableDouble(json, key1, key2);
    return d?.round();
  }

  factory NutritionReport.fromJson(Map<String, dynamic> json) {
    var rawHidden = json['hidden_ingredients'] as List?;
    List<HiddenIngredientReport> parsedHidden = [];
    if (rawHidden != null) {
      parsedHidden = rawHidden
          .map((item) => HiddenIngredientReport.fromJson(item as Map<String, dynamic>))
          .toList();
    }

    final vitC = _tryParseNullableDouble(json, 'vitamin_c_mg', 'vitamin_c');
    String vitaminsStr = "";
    if (json['vitamins_others'] is List) {
      vitaminsStr = (json['vitamins_others'] as List).join(', ');
    } else if (json['vitamins'] is List) {
      vitaminsStr = (json['vitamins'] as List).join(', ');
    } else {
      vitaminsStr = json['vitamins_others']?.toString() ?? json['vitamins']?.toString() ?? "";
    }

    if (vitaminsStr == "[]") {
      vitaminsStr = "";
    }

    if (vitC != null && vitC > 0) {
      final vitCStr = "Vitamin C (${vitC.toStringAsFixed(0)}mg)";
      vitaminsStr = vitaminsStr.isNotEmpty ? "$vitCStr, $vitaminsStr" : vitCStr;
    }

    if (vitaminsStr.isEmpty) {
      vitaminsStr = "None";
    }

    return NutritionReport(
      mealName: json['meal_name']?.toString() ?? "Unknown Meal",
      totalCalories:
          double.tryParse(json['total_calories']?.toString() ?? "0") ?? 0,
      totalProtein:
          double.tryParse(json['total_protein']?.toString() ?? "0") ?? 0.0,
      totalCarbs:
          double.tryParse(json['total_carbs']?.toString() ?? "0") ?? 0.0,
      totalFat: double.tryParse(json['total_fat']?.toString() ?? "0") ?? 0.0,
      sugar: _tryParseNullableDouble(json, 'sugar_g', 'sugar'),
      sodium: _tryParseNullableInt(json, 'sodium_mg', 'sodium'),
      glycemicIndex: (double.tryParse(json['item_gi']?.toString() ?? json['glycemic_index']?.toString() ?? (json['glycemic_index_rating']?.toString().toLowerCase() == 'low' ? '35' : json['glycemic_index_rating']?.toString().toLowerCase() == 'high' ? '75' : '55')) ?? 55.0).round(),
      glycemicLoad: (double.tryParse(json['total_gl']?.toString() ?? json['glycemic_load']?.toString() ?? "0") ?? 0.0).round(),
      magnesium: _tryParseNullableInt(json, 'magnesium_mg', 'magnesium'),
      calcium: _tryParseNullableInt(json, 'calcium_mg', 'calcium'),
      fiber: _tryParseNullableInt(json, 'fiber_g', 'fiber'),
      vitamins: vitaminsStr,
      healthScore: (double.tryParse(json['health_score']?.toString() ?? "0") ?? 0.0).round(),
      healthTip: json['health_tip']?.toString() ?? "No tip provided.",
      warning: json['warning']?.toString() ?? json['metabolic_warning']?.toString() ?? "",
      hiddenIngredients: parsedHidden,
    );
  }
}