import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'app_routes.dart';
import '../../application/auth/auth_provider.dart';
import '../../domain/enums/auth_status.dart';
import '../../presentation/auth/login_screen.dart';
import '../../presentation/auth/register_screen.dart';
import '../../presentation/auth/forgot_password_screen.dart';
import '../../presentation/home/home_screen.dart';
import '../../presentation/admin/admin_dashboard_screen.dart';
import '../../presentation/profile/personal_info_screen.dart';
import '../splash_screen.dart';

class GoRouterRefreshStream extends ChangeNotifier {
  late final StreamSubscription<dynamic> _subscription;

  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen(
          (dynamic _) => notifyListeners(),
        );
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

final routerProvider = Provider<GoRouter>((ref) {
  // Listen to the auth state notifier's stream for refreshes
  final refreshListenable = GoRouterRefreshStream(ref.watch(authProvider.notifier).stream);

  return GoRouter(
    initialLocation: AppRoutes.splash,
    refreshListenable: refreshListenable,
    redirect: (context, state) {
      final authState = ref.read(authProvider);
      final status = authState.status;
      final isAdmin = authState.isAdmin;
      final location = state.uri.path;

      // 1. Unknown status -> show SplashScreen
      if (status == AuthStatus.unknown) {
        if (location != AppRoutes.splash) {
          return AppRoutes.splash;
        }
        return null;
      }

      // 2. Unauthenticated -> trying to access protected route -> redirect to /login
      final isAuthRoute = location == AppRoutes.login ||
          location == AppRoutes.register ||
          location == AppRoutes.forgot;

      if (status == AuthStatus.unauthenticated) {
        if (location == AppRoutes.splash) {
          return AppRoutes.home; // Guest allowed to enter home
        }
        if (location == AppRoutes.admin || location == AppRoutes.personalInfo) {
          return AppRoutes.login;
        }
        if (location != AppRoutes.home && !isAuthRoute) {
          return AppRoutes.login;
        }
        return null;
      }

      // 3. Authenticated + on login/register/forgot -> redirect to /home or /admin
      if (status == AuthStatus.authenticated) {
        if (isAuthRoute || location == AppRoutes.splash) {
          return isAdmin ? AppRoutes.admin : AppRoutes.home;
        }

        // 4. Authenticated but isAdmin=false + trying to access /admin -> redirect to /home
        if (location == AppRoutes.admin && !isAdmin) {
          return AppRoutes.home;
        }
      }

      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.register,
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: AppRoutes.forgot,
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: AppRoutes.home,
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: AppRoutes.admin,
        builder: (context, state) => const AdminDashboardScreen(),
      ),
      GoRoute(
        path: AppRoutes.personalInfo,
        builder: (context, state) => const PersonalInfoScreen(),
      ),
    ],
  );
});
