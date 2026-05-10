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
      sugar: double.tryParse(json['sugar']?.toString() ?? "0") ?? 0.0,
      sodium: int.tryParse(json['sodium']?.toString() ?? "0") ?? 0,
      glycemicIndex:
          int.tryParse(json['glycemic_index']?.toString() ?? "0") ?? 0,
      glycemicLoad: int.tryParse(json['glycemic_load']?.toString() ?? "0") ?? 0,
      magnesium: int.tryParse(json['magnesium']?.toString() ?? "0") ?? 0,
      calcium: int.tryParse(json['calcium']?.toString() ?? "0") ?? 0,
      fiber: int.tryParse(json['fiber']?.toString() ?? "0") ?? 0,
      vitamins: json['vitamins']?.toString() ?? "",
      healthScore: int.tryParse(json['health_score']?.toString() ?? "0") ?? 0,
      healthTip: json['health_tip']?.toString() ?? "No tip provided.",
      warning: json['warning']?.toString() ?? "",
    );
  }
}
