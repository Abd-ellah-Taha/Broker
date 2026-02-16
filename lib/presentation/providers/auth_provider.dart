import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_constants.dart';
import '../../data/repositories/user_repository_impl.dart';
import '../../data/services/auth_service.dart';
import '../../domain/models/user_model.dart';

final authServiceProvider = Provider<AuthService>((ref) => AuthService());

final userRepositoryProvider = Provider<UserRepositoryImpl>((ref) {
  return UserRepositoryImpl();
});

final authStateProvider = StreamProvider<User?>((ref) {
  return ref.watch(authServiceProvider).authStateChanges;
});

final currentUserModelProvider = StreamProvider<UserModel?>((ref) {
  final authState = ref.watch(authStateProvider);
  final userRepo = ref.watch(userRepositoryProvider);
  final authService = ref.watch(authServiceProvider);

  final user = authState.valueOrNull;
  if (user == null) return Stream.value(null);
  return userRepo.watchUser(user.uid).map((model) {
    return model ?? authService.userFromFirebase(user);
  });
});

final isAuthenticatedProvider = Provider<bool>((ref) {
  return ref.watch(authStateProvider).valueOrNull != null;
});

final currentRoleProvider = Provider<String>((ref) {
  final user = ref.watch(currentUserModelProvider).valueOrNull;
  return user?.role ?? AppConstants.roleSeeker;
});
