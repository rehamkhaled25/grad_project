import 'dart:convert';

class UserModel {
  int? id;
  String? fullName;
  String? email;
  String? password; 
  String? birthdate; 
  String? gender;
  String? goal;
  double? weight;
  double? height;
  double? goalWeight;
  List<String>? allergies;

  UserModel({
    this.id,
    this.fullName,
    this.email,
    this.password,
    this.birthdate,
    this.gender,
    this.goal,
    this.weight,
    this.height,
    this.allergies,
     this.goalWeight,
  });

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "full_name": fullName,
      "email": email,
      "password": password,
      "birthdate": birthdate,
      "gender": gender,
      "goal": goal,
      "weight": weight,
      "height": height,
      "allergies": allergies,
      "goal_weight": goalWeight, 
    };
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      fullName: json['full_name'] ?? "",
      email: json['email'] ?? "",
      birthdate: json['birthdate'],
      gender: json['gender'] ?? "N/A",
      goal: json['goal'] ?? "N/A",
      // These conversions ensure strings like "70.5" don't crash the app
      weight: json['weight'] != null ? double.tryParse(json['weight'].toString()) : null,
      height: json['height'] != null ? double.tryParse(json['height'].toString()) : null,
       goalWeight: json['goal_weight'] != null   // ← ADD THIS
          ? double.tryParse(json['goal_weight'].toString())
          : null,
      allergies: json['allergies'] != null ? List<String>.from(json['allergies']) : [],
    );
  }

  UserModel copyWith({
    String? fullName,
    String? email,
    String? password,
    String? birthdate,
    String? gender,
    String? goal,
    double? weight,
    double? height,
      double? goalWeight, 
    List<String>? allergies,
  }) {
    return UserModel(
      id: id,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      password: password ?? this.password,
      birthdate: birthdate ?? this.birthdate,
      gender: gender ?? this.gender,
      goal: goal ?? this.goal,
      weight: weight ?? this.weight,
      height: height ?? this.height,
      allergies: allergies ?? this.allergies,
       goalWeight: goalWeight ?? this.goalWeight, 
    );
  }
}