import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;

  User? get currentUser => _auth.currentUser;

  Future<void> initGoogleSignIn() async {
    await _googleSignIn.initialize();
  }

  // ---------------- EMAIL / PASSWORD ----------------

  Future<User?> registerUser(String email, String password) async {
    try {
      final result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result.user;
    } on FirebaseAuthException catch (e) {
      print("Registration Error: ${e.message}");
      return null;
    }
  }

  Future<User?> loginUser(String email, String password) async {
    try {
      final result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result.user;
    } on FirebaseAuthException catch (e) {
      print("Login Error: ${e.message}");
      return null;
    }
  }

  // ---------------- GOOGLE SIGN IN (v7+) ----------------

  Future<UserCredential?> signInWithGoogle() async {
    try {
      await _googleSignIn.initialize();

      final GoogleSignInAccount googleUser =
          await _googleSignIn.authenticate();

      final GoogleSignInAuthentication googleAuth =
          googleUser.authentication;

      // accessToken REMOVED in v7.2.0
      final credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      );

      return await _auth.signInWithCredential(credential);

    } on GoogleSignInException catch (e) {
      print("Google Sign-In Error Code: ${e.code}");
      return null;

    } on FirebaseAuthException catch (e) {
      print("Firebase Auth Error: ${e.message}");
      return null;

    } catch (e) {
      print("Error during login: $e");
      return null;
    }
  }

  // ---------------- SIGN OUT ----------------

  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      await _auth.signOut();
    } catch (e) {
      print("Sign Out Error: $e");
    }
  }
}

// v7.x came and killed (me) the gsi package
// todo: migrate from v6.x to v7.x code..

// https://www.geeksforgeeks.org/firebase/flutter-google-sign-in-ui-and-authentication/
// even geeksforgeeks have erroneous code

// https://stackoverflow.com/questions/79706789/the-class-googlesignin-doesnt-have-an-unnamed-constructor
// thank god for stackoverflow

// check https://github.com/flutter/packages/blob/main/packages/google_sign_in/google_sign_in/MIGRATION.md
// very funny google.. very funny
