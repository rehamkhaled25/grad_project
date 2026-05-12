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
  String? profileImageUrl;
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
    this.profileImageUrl,
    this.goalWeight,
    this.allergies,
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
      "profile_image_url": profileImageUrl,
      "goal_weight": goalWeight,
      "allergies": allergies,
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
      weight: json['weight'] != null
          ? double.tryParse(json['weight'].toString())
          : null,
      height: json['height'] != null
          ? double.tryParse(json['height'].toString())
          : null,
      profileImageUrl: json['profile_image_url'],
      goalWeight: json['goal_weight'] != null
          ? double.tryParse(json['goal_weight'].toString())
          : null,
      allergies: json['allergies'] != null
          ? List<String>.from(json['allergies'])
          : [],
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
    String? profileImageUrl,
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
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      goalWeight: goalWeight ?? this.goalWeight,
      allergies: allergies ?? this.allergies,
    );
  }
}