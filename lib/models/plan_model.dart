class PlanModel {
  final int calories;
  final int protein;
  final int carbs;
  final int fats;
  final String targetSummary;
  final int healthScore; // Added this
  final String goalDirection; // Added this

  PlanModel({
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fats,
    required this.targetSummary,
    required this.healthScore,
    required this.goalDirection,
  });

  factory PlanModel.fromJson(Map<String, dynamic> json) {
    return PlanModel(
      calories: json['calories'] ?? 0,
      protein: json['protein'] ?? 0,
      carbs: json['carbs'] ?? 0,
      fats: json['fats'] ?? 0,
      targetSummary: json['target_summary'] ?? "",
      healthScore: json['health_score'] ?? 0,
      goalDirection: json['goal_direction'] ?? "maintain_weight",
    );
  }
}