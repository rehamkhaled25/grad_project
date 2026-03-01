class NutritionReport {
  final String mealName;
  final int totalCalories;
  final double totalProtein;
  final double totalCarbs;
  final double totalFat;
  final int healthScore;
  final String healthTip;

  NutritionReport({
    required this.mealName,
    required this.totalCalories,
    required this.totalProtein,
    required this.totalCarbs,
    required this.totalFat,
    required this.healthScore,
    required this.healthTip,
  });

  factory NutritionReport.fromJson(Map<String, dynamic> json) {
    return NutritionReport(
      mealName: json['meal_name']?.toString() ?? "Unknown Meal",
      totalCalories: int.tryParse(json['total_calories']?.toString() ?? "0") ?? 0,
      totalProtein: double.tryParse(json['total_protein']?.toString() ?? "0") ?? 0.0,
      totalCarbs: double.tryParse(json['total_carbs']?.toString() ?? "0") ?? 0.0,
      totalFat: double.tryParse(json['total_fat']?.toString() ?? "0") ?? 0.0,
      healthScore: int.tryParse(json['health_score']?.toString() ?? "0") ?? 0,
      healthTip: json['health_tip']?.toString() ?? "No tip provided.",
    );
  }
}