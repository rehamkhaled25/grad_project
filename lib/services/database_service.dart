// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:graduation_project/models/user_model.dart';

// class DatabaseService {
//   final FirebaseFirestore _db = FirebaseFirestore.instance;

//   // create or overwrite user profile
//   Future<void> saveUserData(UserModel user) async {
//     try {
//       // access the 'users' collection and use the user's uid as the document id
//       await _db.collection('users').doc(user.uid).set(
//             user.toMap(),
//             SetOptions(merge: true), // merge prevents overwriting existing data
//           );
//       print("User ${user.uid} saved successfully.");
//     } catch (e) {
//       print("Error saving user data: $e");
//       rethrow; 
//     }
//   }

//   // get a one-time snapshot of user profile by UID
//   Future<UserModel?> getUserData(String uid) async {
//     try {
//       DocumentSnapshot doc = await _db.collection('users').doc(uid).get();
      
//       if (doc.exists && doc.data() != null) {
//         // convert the firebase map back into our dart usermodel object
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

//   // listen to user changes in real-time
//   Stream<UserModel?> streamUserData(String uid) {
//     return _db.collection('users').doc(uid).snapshots().map((doc) {
//       if (doc.exists && doc.data() != null) {
//         return UserModel.fromMap(doc.data() as Map<String, dynamic>);
//       }
//       return null;
//     });
//   }
// }