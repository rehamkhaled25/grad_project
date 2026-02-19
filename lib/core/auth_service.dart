import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // تسجيل دخول باستخدام البريد الإلكتروني وكلمة المرور
  Future<User?> signIn(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } catch (e) {
      // معالجة الأخطاء بشكل أفضل
      print('Failed to sign in: $e');
      // يمكننا إضافة إشعار للمستخدم في المستقبل أو التعامل مع الأخطاء بطريقة أفضل
      return null; // إرجاع null إذا فشل تسجيل الدخول
    }
  }

  // التسجيل باستخدام البريد الإلكتروني وكلمة المرور
  Future<User?> register(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } catch (e) {
      // معالجة الأخطاء بشكل أفضل
      print('Failed to register: $e');
      // يمكننا إضافة إشعار للمستخدم في المستقبل أو التعامل مع الأخطاء بطريقة أفضل
      return null; // إرجاع null إذا فشل التسجيل
    }
  }

  // تسجيل الخروج
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      print('Error during sign out: $e');
    }
  }

  // للحصول على المستخدم الحالي
  Future<User?> getCurrentUser() async {
    return _auth.currentUser;
  }

  // إعادة تعيين كلمة المرور
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      print('Error during password reset: $e');
    }
  }
}
