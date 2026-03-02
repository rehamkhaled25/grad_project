// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:graduation_project/models/user_model.dart';

// class DatabaseService {
//   final FirebaseFirestore _db = FirebaseFirestore.instance;

//   // FETCH: Get user profile by UID
//   Future<UserModel?> getUserData(String uid) async {
//     try {
//       DocumentSnapshot doc = await _db.collection('users').doc(uid).get();
      
//       if (doc.exists) {
//         return UserModel.fromMap(doc.data() as Map<String, dynamic>);
//       } else {
//         print("No user found with UID: $uid");
//         return null;
//       }
//     } catch (e) {
//       print("Error fetching user data: $e");
//       return null;
//     }
//   }

//   // STREAM: Listen to user changes in real-time (Great for Dashboards)
//   Stream<UserModel?> streamUserData(String uid) {
//     return _db.collection('users').doc(uid).snapshots().map((doc) {
//       if (doc.exists && doc.data() != null) {
//         return UserModel.fromMap(doc.data() as Map<String, dynamic>);
//       }
//       return null;
//     });
//   }
// }
