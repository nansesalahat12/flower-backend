import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // تسجيل مستخدم جديد
  Future<User?> signUpWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result.user;
    } on FirebaseAuthException catch (e) {
      throw Exception(_getErrorMessage(e.code));
    }
  }

  // تسجيل دخول مستخدم
  Future<User?> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result.user;
    } on FirebaseAuthException catch (e) {
      throw Exception(_getErrorMessage(e.code));
    }
  }

  // تسجيل خروج
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // عرض رسائل خطأ أوضح للمستخدم
  String _getErrorMessage(String code) {
    switch (code) {
      case 'email-already-in-use':
        return 'هذا البريد مستخدم بالفعل';
      case 'invalid-email':
        return 'البريد الإلكتروني غير صحيح';
      case 'weak-password':
        return 'كلمة المرور ضعيفة';
      case 'user-not-found':
        return 'لا يوجد حساب بهذا البريد';
      case 'wrong-password':
        return 'كلمة المرور غير صحيحة';
      default:
        return 'حدث خطأ، حاول مرة أخرى';
    }
  }
}
