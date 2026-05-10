import 'dart:convert';

class UserModel {
  int? id;
  String? fullName;
  String? email;
  String? password; // Used for registration only, not stored in cleartext in DB
  String? birthdate; // Stored as "YYYY-MM-DD" to match Flask's db.Date requirements
  String? gender;
  String? goal;
  double? weight;
  double? height;

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
  });

  /// 1. Converts the Flutter Object into a Map (JSON) to send to your Flask Backend.
  /// Used in: ApiService.signup()
  Map<String, dynamic> toJson() {
    return {
      "full_name": fullName,
      "email": email,
      "password": password,
      "birthdate": birthdate,
      "gender": gender,
      "goal": goal,
      "weight": weight,
      "height": height,
    };
  }

  /// 2. Creates a Flutter Object from the JSON data received from Flask.
  /// Used in: ApiService.login() or fetching user profile
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      fullName: json['full_name'],
      email: json['email'],
      // Password is never returned from the backend for security
      birthdate: json['birthdate'],
      gender: json['gender'],
      goal: json['goal'],
      weight: json['weight']?.toDouble(), // Safely handle int-to-double conversion
      height: json['height']?.toDouble(),
    );
  }

  /// Helper method to create a copy of the user with updated fields 
  /// (Useful for passing the model between onboarding screens)
  UserModel copyWith({
    String? fullName,
    String? email,
    String? password,
    String? birthdate,
    String? gender,
    String? goal,
    double? weight,
    double? height,
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
    );
  }
}