import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_constants.dart';
import 'auth_provider.dart';
import '../../data/repositories/user_repository_impl.dart';
import '../../data/services/auth_service.dart';

/// Handles auth flows: send OTP, verify OTP, Google sign-in, create user in Firestore.
class AuthFlowsNotifier extends StateNotifier<void> {
  AuthFlowsNotifier(this._auth, this._userRepo) : super(null);

  final AuthService _auth;
  final UserRepositoryImpl _userRepo;

  Future<void> sendOTP(String phone) async {
    await _auth.verifyPhoneNumber(
      phoneNumber: phone,
      codeSent: (verificationId, _) {
        _pendingVerificationId = verificationId;
      },
      verificationCompleted: (credential) async {
        await _auth.signInWithCredential(credential);
        await _ensureUserInFirestore();
      },
      verificationFailed: (e) => throw Exception(e.message ?? 'Verification failed'),
      codeAutoRetrievalTimeout: (_) {},
    );
  }

  String? _pendingVerificationId;

  Future<void> verifyOTP(String code) async {
    final id = _pendingVerificationId;
    if (id == null) throw Exception('No pending verification');
    final credential = PhoneAuthProvider.credential(
      verificationId: id,
      smsCode: code,
    );
    await _auth.signInWithCredential(credential);
    await _ensureUserInFirestore();
  }

  Future<void> signInWithGoogle() async {
    final cred = await _auth.signInWithGoogle();
    await _ensureUserInFirestore();
  }

  Future<void> _ensureUserInFirestore() async {
    final user = _auth.currentUser;
    if (user == null) return;
    var model = await _userRepo.getUserById(user.uid);
    if (model == null) {
      model = _auth.userFromFirebase(user);
      await _userRepo.createOrUpdateUser(model);
    }
  }

  Future<void> updateRole(String role) async {
    final user = _auth.currentUser;
    if (user == null) return;
    var model = await _userRepo.getUserById(user.uid);
    if (model != null) {
      model = model.copyWith(role: role);
      await _userRepo.createOrUpdateUser(model);
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }
}

final authFlowsProvider =
    StateNotifierProvider<AuthFlowsNotifier, void>((ref) {
  return AuthFlowsNotifier(
    ref.read(authServiceProvider),
    ref.read(userRepositoryProvider),
  );
});
