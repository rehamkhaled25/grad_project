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

class NutritionReport {
  final String mealName;
  final double totalCalories;
  final double totalProtein;
  final double totalCarbs;
  final double totalFat;
  final double sugar;
  final int sodium;
  final int glycemicIndex;
  final int glycemicLoad;
  final int magnesium;
  final int calcium;
  final int fiber;
  final String vitamins;
  final int healthScore;
  final String healthTip;
  final String warning;

  NutritionReport({
    required this.mealName,
    required this.totalCalories,
    required this.totalProtein,
    required this.totalCarbs,
    required this.totalFat,
    required this.sugar,
    required this.sodium,
    required this.glycemicIndex,
    required this.glycemicLoad,
    required this.magnesium,
    required this.calcium,
    required this.fiber,
    required this.vitamins,
    required this.healthScore,
    required this.healthTip,
    required this.warning,
  });

  factory NutritionReport.fromJson(Map<String, dynamic> json) {
    return NutritionReport(
      mealName: json['meal_name']?.toString() ?? "Unknown Meal",
      totalCalories:
          double.tryParse(json['total_calories']?.toString() ?? "0") ?? 0,
      totalProtein:
          double.tryParse(json['total_protein']?.toString() ?? "0") ?? 0.0,
      totalCarbs:
          double.tryParse(json['total_carbs']?.toString() ?? "0") ?? 0.0,
      totalFat: double.tryParse(json['total_fat']?.toString() ?? "0") ?? 0.0,
      sugar: double.tryParse(json['sugar_g']?.toString() ?? json['sugar']?.toString() ?? "0") ?? 0.0,
      sodium: int.tryParse(json['sodium_mg']?.toString() ?? json['sodium']?.toString() ?? "0") ?? 0,
      glycemicIndex:
          int.tryParse(json['item_gi']?.toString() ?? json['glycemic_index']?.toString() ?? (json['glycemic_index_rating']?.toString().toLowerCase() == 'low' ? '35' : json['glycemic_index_rating']?.toString().toLowerCase() == 'high' ? '75' : '55')) ?? 55,
      glycemicLoad: int.tryParse(json['total_gl']?.toString() ?? json['glycemic_load']?.toString() ?? "0") ?? 0,
      magnesium: int.tryParse(json['magnesium_mg']?.toString() ?? json['magnesium']?.toString() ?? "0") ?? 0,
      calcium: int.tryParse(json['calcium_mg']?.toString() ?? json['calcium']?.toString() ?? "0") ?? 0,
      fiber: int.tryParse(json['fiber_g']?.toString() ?? json['fiber']?.toString() ?? "0") ?? 0,
      vitamins: json['vitamins_others']?.toString() ?? json['vitamins']?.toString() ?? "",
      healthScore: int.tryParse(json['health_score']?.toString() ?? "0") ?? 0,
      healthTip: json['health_tip']?.toString() ?? "No tip provided.",
      warning: json['warning']?.toString() ?? json['metabolic_warning']?.toString() ?? "",
    );
  }
}