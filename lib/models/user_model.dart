import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String email;
  final String? fullName;
  final DateTime? birthdate;
  final String? gender;
  final String? goal;
  final double? weight;
  final double? height;

  UserModel({
    required this.uid,
    required this.email,
    this.fullName,
    this.birthdate,
    this.gender,
    this.goal,
    this.weight,
    this.height,
  });


  Map<String, dynamic> toMap() {
    final Map<String, dynamic> map = {
      'uid': uid,
      'email': email,
    };

    if (fullName != null) map['fullName'] = fullName;
    if (birthdate != null) map['birthdate'] = birthdate;
    if (gender != null) map['gender'] = gender;
    if (goal != null) map['goal'] = goal;
    if (weight != null) map['weight'] = weight;
    if (height != null) map['height'] = height;

    return map;
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      email: map['email'] ?? '',
      fullName: map['fullName'],
      birthdate: map['birthdate'] != null 
          ? (map['birthdate'] as Timestamp).toDate() 
          : null,
      gender: map['gender'],
      goal: map['goal'],
      weight: map['weight'] != null ? (map['weight'] as num).toDouble() : null,
      height: map['height'] != null ? (map['height'] as num).toDouble() : null,
    );
  }
}