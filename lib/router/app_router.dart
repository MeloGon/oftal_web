import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:oftal_web/features/sell/views/sell_view.dart';
import 'package:oftal_web/features/views.dart';
import 'package:oftal_web/router/router_name.dart';
import 'package:oftal_web/shared/layouts/auth/auth_layout.dart';
import 'package:oftal_web/shared/layouts/dashboard/dashboard_layout.dart';
import 'package:oftal_web/shared/layouts/splash/splash_layout.dart';
import 'package:oftal_web/shared/providers/providers.dart';
import 'package:oftal_web/shared/views/dashboard_view.dart';
import 'package:oftal_web/shared/views/no_page_found_view.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'app_router.g.dart';

@riverpod
GoRouter appRouter(Ref ref) {
  return GoRouter(
    initialLocation: RouterName.login,
    debugLogDiagnostics: false,
    redirect: (context, state) {
      final status = ref.watch(authProvider).status;
      final loc = state.matchedLocation;

      final inAuth = loc.startsWith('/auth');
      final inDashboard = loc.startsWith('/dashboard');

      // 1) Mientras verifica, no redirijas
      if (status == AuthStatus.checking) return RouterName.splash;

      // 2) Autenticado: permite /dashboard y subrutas; solo bloquea /auth/*
      if (status == AuthStatus.authenticated) {
        return inAuth ? RouterName.dashboard : null;
      }

      // 3) No autenticado: permite /auth/*; bloquea /dashboard/*
      if (status == AuthStatus.notAuthenticated) {
        return inDashboard ? RouterName.login : null;
      }

      return null;
    },
    errorBuilder: (context, state) {
      debugPrint('error: ${state.error}');
      return const NoPageFoundView();
    },

    routes: [
      ShellRoute(
        builder: (context, state, child) => const SplashLayout(),
        routes: [
          GoRoute(
            path: RouterName.splash,
            pageBuilder: (context, state) => _fadeRoute(const SplashLayout()),
          ),
        ],
      ),
      ShellRoute(
        builder: (context, state, child) => AuthLayout(child: child),
        routes: [
          GoRoute(
            path: RouterName.login,
            pageBuilder: (context, state) => _fadeRoute(const LoginView()),
          ),
        ],
      ),
      ShellRoute(
        builder: (context, state, child) => DashboardLayout(child: child),
        routes: [
          GoRoute(
            path: RouterName.dashboard,
            pageBuilder: (context, state) => _fadeRoute(const DashboardView()),
          ),
          GoRoute(
            path: RouterName.addPatient,
            pageBuilder: (context, state) => _fadeRoute(const AddPatientView()),
            redirect: (context, state) {
              if (state.matchedLocation == RouterName.addPatient) {
                ref
                    .read(navigationProvider.notifier)
                    .setCurrentPage(RouterName.addPatient);
                return RouterName.addPatient;
              }
              return null;
            },
          ),
          GoRoute(
            path: RouterName.settings,
            pageBuilder: (context, state) => _fadeRoute(const SettingsView()),
            redirect: (context, state) {
              if (state.matchedLocation == RouterName.settings) {
                ref
                    .read(navigationProvider.notifier)
                    .setCurrentPage(RouterName.settings);
                return RouterName.settings;
              }
              return null;
            },
          ),
          GoRoute(
            path: RouterName.sell,
            pageBuilder: (context, state) => _fadeRoute(const SellView()),
            redirect: (context, state) {
              if (state.matchedLocation == RouterName.sell) {
                ref
                    .read(navigationProvider.notifier)
                    .setCurrentPage(RouterName.sell);
                return RouterName.sell;
              }
              return null;
            },
          ),
        ],
      ),
    ],
  );
}

CustomTransitionPage _fadeRoute(Widget child) {
  return CustomTransitionPage(
    transitionDuration: const Duration(milliseconds: 200),
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(
        opacity: animation,
        child: child,
      );
    },
  );
}
