// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:google_sign_in/google_sign_in.dart';

// class AuthService {
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//   final GoogleSignIn _googleSignIn = GoogleSignIn.instance;

//   User? get currentUser => _auth.currentUser;

//   Future<void> initGoogleSignIn() async {
//     await _googleSignIn.initialize();
//   }

//   // ---------------- EMAIL / PASSWORD ----------------

//   Future<User?> registerUser(String email, String password) async {
//     try {
//       final result = await _auth.createUserWithEmailAndPassword(
//         email: email,
//         password: password,
//       );
//       return result.user;
//     } on FirebaseAuthException catch (e) {
//       print("Registration Error: ${e.message}");
//       return null;
//     }
//   }

//   Future<User?> loginUser(String email, String password) async {
//     try {
//       final result = await _auth.signInWithEmailAndPassword(
//         email: email,
//         password: password,
//       );
//       return result.user;
//     } on FirebaseAuthException catch (e) {
//       print("Login Error: ${e.message}");
//       return null;
//     }
//   }

//   // ---------------- GOOGLE SIGN IN (v7+) ----------------1

//   Future<UserCredential?> signInWithGoogle() async {
//     try {
//       await _googleSignIn.initialize();

//       final GoogleSignInAccount googleUser =
//           await _googleSignIn.authenticate();

//       final GoogleSignInAuthentication googleAuth =
//           googleUser.authentication;

//       // accessToken REMOVED in v7.2.0
//       final credential = GoogleAuthProvider.credential(
//         idToken: googleAuth.idToken,
//       );

//       return await _auth.signInWithCredential(credential);

//     } on GoogleSignInException catch (e) {
//       print("Google Sign-In Error Code: ${e.code}");
//       return null;

//     } on FirebaseAuthException catch (e) {
//       print("Firebase Auth Error: ${e.message}");
//       return null;

//     } catch (e) {
//       print("Error during login: $e");
//       return null;
//     }
//   }

//   // ---------------- SIGN OUT ----------------

//   Future<void> signOut() async {
//     try {
//       await _googleSignIn.signOut();
//       await _auth.signOut();
//     } catch (e) {
//       print("Sign Out Error: $e");
//     }
//   }
// }



////// my code /////
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:google_sign_in/google_sign_in.dart';

// class AuthService {

//   final FirebaseAuth _auth = FirebaseAuth.instance;
//    final GoogleSignIn _googleSignIn = GoogleSignIn.instance;
//  bool _isGoogleInitialized = false;
// User? get currentUser => _auth.currentUser;
// Future<void> initGoogleSignIn() async {
//  if (_isGoogleInitialized) return;

//     try {

//       print("DEBUG: Initializing Google Sign-In...");

//       await _googleSignIn.initialize();

//       _isGoogleInitialized = true;

//       print("DEBUG: Google Sign-In Initialized Successfully.");

//     } catch (e) {

//       print("DEBUG ERROR: Initialization failed: $e");

//       rethrow;

//     }

//   }



//   // ---------------- EMAIL / PASSWORD REGISTRATION ----------------

//   Future<User?> registerUser(String email, String password) async {

//     try {

//       print("DEBUG: Attempting to Register: $email");

//       final result = await _auth.createUserWithEmailAndPassword(

//         email: email,

//         password: password,

//       );

//       print("DEBUG: Registration SUCCESS for ${result.user?.email}");

//       return result.user;

//     } on FirebaseAuthException catch (e) {

//       // This will tell you EXACTLY why it failed in the console

//       print("DEBUG ERROR (Firebase Register): ${e.code} - ${e.message}");

//       return null;

//     } catch (e) {

//       print("DEBUG ERROR (General Register): $e");

//       return null;

//     }

//   }



//   // ---------------- EMAIL / PASSWORD LOGIN ----------------

//   Future<User?> loginUser(String email, String password) async {

//     try {

//       print("DEBUG: Attempting Email Login for: $email");

//       final result = await _auth.signInWithEmailAndPassword(

//         email: email,

//         password: password,

//       );

//       print("DEBUG: Email Login Success!");

//       return result.user;

//     } on FirebaseAuthException catch (e) {

//       print("DEBUG ERROR (Firebase Login): ${e.code} - ${e.message}");

//       return null;

//     }

//   }



//   // ---------------- GOOGLE SIGN IN ----------------

//   Future<UserCredential?> signInWithGoogle() async {

//     try {

//       await initGoogleSignIn();



//       print("DEBUG: Opening Google Selector...");

//       GoogleSignInAccount? googleUser;



//       if (await _googleSignIn.supportsAuthenticate()) {

//         googleUser = await _googleSignIn.authenticate();

//       } else {

//         print("DEBUG ERROR: authenticate() not supported on this platform.");

//         return null;

//       }
//  if (googleUser == null) {

//         print("DEBUG: User closed the Google popup (Cancelled).");

//         return null;
//       }
//  print("DEBUG: Google User obtained: ${googleUser.email}");

     

//       final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

//       print("DEBUG: Tokens received. idToken is null: ${googleAuth.idToken == null}");



//       final credential = GoogleAuthProvider.credential(

//         idToken: googleAuth.idToken,

//       );
//  print("DEBUG: Sending Credential to Firebase...");

//       final userCredential = await _auth.signInWithCredential(credential);
//       print("DEBUG: Firebase Google Login/Register SUCCESS!");
//  return userCredential;

//     } on FirebaseAuthException catch (e) {

//       print("DEBUG ERROR (Firebase Google): ${e.code} - ${e.message}");

//       return null;

//     } catch (e) {

//       print("DEBUG ERROR (General Google): $e");

//       return null;

//     }

//   }
// Future<void> signOut() async {

//     try {

//       await _googleSignIn.signOut();

//       await _auth.signOut();

//       print("DEBUG: Signed Out.");

//     } catch (e) {

//       print("DEBUG ERROR (SignOut): $e");

//     }
//   }
// } // i used your code just added extra prints for debugging 



import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;
  bool _isGoogleInitialized = false;

  User? get currentUser => _auth.currentUser;

  // Initialize Google Sign-In properly for v7+
  Future<void> initGoogleSignIn() async {
    if (_isGoogleInitialized) return;
    try {
      print("DEBUG: Initializing Google Sign-In...");
      await _googleSignIn.initialize();
      _isGoogleInitialized = true;
      print("DEBUG: Google Sign-In Initialized Successfully.");
    } catch (e) {
      print("DEBUG ERROR: Initialization failed: $e");
      rethrow;
    }
  }

  // ---------------- EMAIL / PASSWORD REGISTRATION ----------------
  Future<User?> registerUser(String email, String password) async {
    try {
      print("DEBUG: Attempting to Register: $email");
      final result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      print("DEBUG: Registration SUCCESS for ${result.user?.email}");
      return result.user;
    } on FirebaseAuthException catch (e) {
      // This prints the exact error (like email-already-in-use) to your console
      print("DEBUG ERROR (Firebase Register): ${e.code} - ${e.message}");
      return null;
    } catch (e) {
      print("DEBUG ERROR (General Register): $e");
      return null;
    }
  }

  // ---------------- EMAIL / PASSWORD LOGIN ----------------
  Future<User?> loginUser(String email, String password) async {
    try {
      print("DEBUG: Attempting Email Login for: $email");
      final result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      print("DEBUG: Email Login Success!");
      return result.user;
    } on FirebaseAuthException catch (e) {
      print("DEBUG ERROR (Firebase Login): ${e.code} - ${e.message}");
      return null;
    } catch (e) {
      print("DEBUG ERROR: $e");
      return null;
    }
  }

  // ---------------- GOOGLE SIGN IN (Android Optimized v7+) ----------------
  Future<UserCredential?> signInWithGoogle() async {
    try {
      await initGoogleSignIn();

      print("DEBUG: Opening Google Selector...");
      GoogleSignInAccount? googleUser;

      // The authenticate() method is the standard for version 7.0+
      if (await _googleSignIn.supportsAuthenticate()) {
        googleUser = await _googleSignIn.authenticate();
      } else {
        print("DEBUG ERROR: authenticate() not supported on this device.");
        return null;
      }

      if (googleUser == null) {
        print("DEBUG: User closed the Google popup.");
        return null;
      }

      print("DEBUG: Google User obtained: ${googleUser.email}");

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      
      // On Android, the idToken is the core requirement for Firebase
      if (googleAuth.idToken == null) {
        print("DEBUG ERROR: idToken is NULL. Check Firebase Support Email and SHA-1.");
        return null;
      }

      final credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      );

      print("DEBUG: Sending Credential to Firebase...");
      final userCredential = await _auth.signInWithCredential(credential);
      print("DEBUG: Firebase Google Login SUCCESS!");
      
      return userCredential;

    } on FirebaseAuthException catch (e) {
      print("DEBUG ERROR (Firebase Google): ${e.code} - ${e.message}");
      return null;
    } catch (e) {
      print("DEBUG ERROR (General Google): $e");
      return null;
    }
  }

  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      await _auth.signOut();
      print("DEBUG: Signed Out.");
    } catch (e) {
      print("DEBUG ERROR (SignOut): $e");
    }
  }
}