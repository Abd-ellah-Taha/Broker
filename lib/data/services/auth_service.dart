import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../core/constants/app_constants.dart';
import '../../domain/models/user_model.dart';

/// Auth service: Phone OTP + Google Sign-in.
/// Egyptian phone format: +20 1X XXXXXXXX (10 digits after +20).
class AuthService {
  AuthService({
    FirebaseAuth? auth,
    GoogleSignIn? googleSignIn,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _googleSignIn = googleSignIn ?? GoogleSignIn();

  final FirebaseAuth _auth;
  final GoogleSignIn _googleSignIn;

  User? get currentUser => _auth.currentUser;
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Normalize Egyptian phone to E.164: +20XXXXXXXXX
  static String normalizeEgyptPhone(String input) {
    final digits = input.replaceAll(RegExp(r'\D'), '');
    if (digits.length == 10 && digits.startsWith('1')) {
      return '+20$digits';
    }
    if (digits.length == 11 && digits.startsWith('01')) {
      return '+20${digits.substring(1)}';
    }
    if (digits.length == 12 && digits.startsWith('20')) {
      return '+$digits';
    }
    return input.startsWith('+') ? input : '+$input';
  }

  Future<void> verifyPhoneNumber({
    required String phoneNumber,
    required void Function(String verificationId, int? resendToken) codeSent,
    required void Function(PhoneAuthCredential credential) verificationCompleted,
    required void Function(FirebaseAuthException e) verificationFailed,
    required void Function(String verificationId) codeAutoRetrievalTimeout,
  }) {
    final normalized = normalizeEgyptPhone(phoneNumber);
    return _auth.verifyPhoneNumber(
      phoneNumber: normalized,
      verificationCompleted: verificationCompleted,
      verificationFailed: verificationFailed,
      codeSent: codeSent,
      codeAutoRetrievalTimeout: codeAutoRetrievalTimeout,
      timeout: const Duration(seconds: 60),
    );
  }

  Future<UserCredential> signInWithCredential(PhoneAuthCredential credential) {
    return _auth.signInWithCredential(credential);
  }

  Future<UserCredential> signInWithGoogle() async {
    final gUser = await _googleSignIn.signIn();
    if (gUser == null) throw Exception('Google sign-in cancelled');
    final gAuth = await gUser.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: gAuth.accessToken,
      idToken: gAuth.idToken,
    );
    return _auth.signInWithCredential(credential);
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }

  Future<void> deleteAccount() async {
    await _auth.currentUser?.delete();
  }

  /// Build UserModel from Firebase User (for Firestore sync).
  UserModel userFromFirebase(User user) {
    final phone = user.phoneNumber ?? user.email ?? user.uid;
    return UserModel(
      id: user.uid,
      phoneNumber: phone,
      displayName: user.displayName,
      email: user.email,
      photoUrl: user.photoURL,
      role: AppConstants.roleSeeker,
      createdAt: null,
      updatedAt: null,
    );
  }
}
