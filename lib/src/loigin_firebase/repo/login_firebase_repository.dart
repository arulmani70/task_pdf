import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:task_pdf/src/common/common.dart';
import 'package:task_pdf/src/common/models/models.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:logger/logger.dart';

class LoginFirebaseRepository {
  final FirebaseAuth _firebaseAuth;
  final PreferencesRepository prefRepo;
  final ApiRepository apiRepo;

  LoginFirebaseRepository({
    FirebaseAuth? firebaseAuth,
    required this.prefRepo,
    required this.apiRepo,
  }) : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance;

  final log = Logger();
  Future<UsersModel?> signInWithEmail(String email, String password) async {
    try {
      UserCredential userCredential = await _firebaseAuth
          .signInWithEmailAndPassword(email: email, password: password);

      User? firebaseUser = userCredential.user;

      if (firebaseUser != null) {
        return UsersModel.fromFirebaseUser(firebaseUser);
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  Future<UsersModel?> registerWithEmail({
    required String email,
    required String password,
    required String fullName,
    required String phone,
  }) async {
    try {
      UserCredential userCredential = await _firebaseAuth
          .createUserWithEmailAndPassword(email: email, password: password);

      final user = userCredential.user;

      if (user != null) {
        await user.updateDisplayName(fullName);

        final userModel = UsersModel(
          id: user.uid,
          name: fullName,
          email: user.email ?? '',
          roleId: '',
          phone: phone,
          createdAt: DateTime.now().toIso8601String(),
        );

        // 🔥 Store in Firestore
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .set(userModel.toJson());

        return userModel;
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  Future<UsersModel?> getCurrentUser() async {
    final user = _firebaseAuth.currentUser;
    if (user != null) {
      return UsersModel.fromFirebaseUser(user);
    } else {
      return null;
    }
  }

  Future<void> signOut() async {
    log.d("LoginFirebaseRepository :: signOut ");
    await _firebaseAuth.signOut();
  }

  Future<void> sendPasswordResetEmail({required String email}) async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      log.d(' Mail sent!');
    } catch (e) {
      log.d(' Error: $e');
    }
  }
}
