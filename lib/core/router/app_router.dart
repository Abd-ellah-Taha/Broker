import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../presentation/screens/auth/login_screen.dart';
import '../../presentation/screens/auth/otp_screen.dart';
import '../../presentation/screens/auth/role_selection_screen.dart';
import '../../presentation/screens/booking/booking_screen.dart';
import '../../presentation/screens/chat/chat_screen.dart';
import '../../presentation/screens/home/home_screen.dart';
import '../../presentation/screens/admin/admin_dashboard_screen.dart';
import '../../presentation/screens/escrow/escrow_screen.dart';
import '../../presentation/screens/property/add_property_screen.dart';
import '../../presentation/screens/property_details/property_details_screen.dart';
import '../../presentation/providers/auth_provider.dart';

/// App routes.
class AppRoutes {
  static const String home = '/';
  static const String login = '/auth/login';
  static const String otp = '/auth/otp';
  static const String roleSelection = '/auth/role';
  static const String propertyDetails = '/property/:id';
}

String propertyDetailsPath(String id) => '/property/$id';

final appRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: AppRoutes.home,
    debugLogDiagnostics: true,
      redirect: (context, state) {
      final isLoggedIn = authState.valueOrNull != null;
      final loc = state.matchedLocation;
      final isAuthRoute = loc.startsWith('/auth/');
      final isRoleSelection = loc == AppRoutes.roleSelection;

      // الصفحات المحمية (تتطلب تسجيل دخول)
      final protectedPaths = ['/property/add', '/admin', '/chat', '/booking', '/escrow', '/edit'];
      final isProtected = protectedPaths.any((p) => loc.contains(p));

      if (!isLoggedIn && isProtected) return AppRoutes.login;
      if (isLoggedIn && isAuthRoute && !isRoleSelection) return AppRoutes.home;
      return null;
    },
    routes: [
      GoRoute(path: AppRoutes.home, builder: (_, __) => const HomeScreen()),
      GoRoute(path: AppRoutes.login, builder: (_, __) => const LoginScreen()),
      GoRoute(
        path: '/auth/otp',
        builder: (context, state) {
          final phone = state.extra is String ? state.extra as String : '';
          return OtpScreen(phone: phone);
        },
      ),
      GoRoute(
        path: AppRoutes.roleSelection,
        builder: (_, __) => const RoleSelectionScreen(),
      ),
      GoRoute(
        path: '/property/:id',
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          return PropertyDetailsScreen(propertyId: id);
        },
      ),
      GoRoute(
        path: '/property/add',
        builder: (_, __) => const AddPropertyScreen(),
      ),
      GoRoute(
        path: '/property/:id/edit',
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          return AddPropertyScreen(propertyId: id);
        },
      ),
      GoRoute(
        path: '/property/:id/chat',
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          final extra = state.extra as Map<String, dynamic>?;
          final ownerId = extra?['ownerId'] as String? ?? '';
          return ChatScreen(
            propertyId: id,
            otherUserId: ownerId,
            otherUserName: 'Owner',
          );
        },
      ),
      GoRoute(
        path: '/property/:id/booking',
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          return BookingScreen(propertyId: id);
        },
      ),
      GoRoute(
        path: '/admin',
        builder: (_, __) => const AdminDashboardScreen(),
      ),
      GoRoute(
        path: '/property/:id/escrow',
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          final extra = state.extra as Map<String, dynamic>?;
          final amount = (extra?['amount'] as num?)?.toDouble() ?? 1000;
          return EscrowScreen(propertyId: id, amount: amount);
        },
      ),
    ],
  );
});
