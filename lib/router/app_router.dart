import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:oftal_web/features/search_patient/views/search_patient_view.dart';
import 'package:oftal_web/features/sell/views/sell_view.dart';
import 'package:oftal_web/features/expenses/views/expenses_view.dart';
import 'package:oftal_web/features/sales_history/views/sales_history_view.dart';
import 'package:oftal_web/features/settings/views/audit_logs/audit_logs_view.dart';
import 'package:oftal_web/features/settings/views/features/features_view.dart';
import 'package:oftal_web/features/settings/views/payments_report/payments_report_view.dart';
import 'package:oftal_web/features/settings/views/mounts/mounts_view.dart';
import 'package:oftal_web/features/settings/views/resins/resins_view.dart';
import 'package:oftal_web/features/views.dart';
import 'package:oftal_web/router/router_name.dart';
import 'package:oftal_web/shared/layouts/auth/auth_layout.dart';
import 'package:oftal_web/shared/layouts/dashboard/dashboard_layout.dart';
import 'package:oftal_web/shared/layouts/splash/splash_layout.dart';
import 'package:oftal_web/shared/providers/providers.dart';
import 'package:oftal_web/features/dashboard/views/dashboard_view.dart';
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
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            DashboardLayout(child: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RouterName.dashboard,
                pageBuilder:
                    (context, state) => _fadeRoute(const DashboardView()),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RouterName.searchPatient,
                pageBuilder:
                    (context, state) =>
                        _fadeRoute(const SearchPatientView()),
                redirect: (context, state) {
                  ref
                      .read(navigationProvider.notifier)
                      .setCurrentPage(RouterName.searchPatient);
                  return null;
                },
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RouterName.addPatient,
                pageBuilder:
                    (context, state) => _fadeRoute(const AddPatientView()),
                redirect: (context, state) {
                  ref
                      .read(navigationProvider.notifier)
                      .setCurrentPage(RouterName.addPatient);
                  return null;
                },
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RouterName.settings,
                pageBuilder:
                    (context, state) => _fadeRoute(const SettingsView()),
                redirect: (context, state) {
                  ref
                      .read(navigationProvider.notifier)
                      .setCurrentPage(RouterName.settings);
                  return null;
                },
                routes: [
                  GoRoute(
                    path: 'resins',
                    pageBuilder:
                        (context, state) => _fadeRoute(const ResinsView()),
                  ),
                  GoRoute(
                    path: 'mounts',
                    pageBuilder:
                        (context, state) => _fadeRoute(const MountsView()),
                  ),
                  GoRoute(
                    path: 'payments-report',
                    pageBuilder:
                        (context, state) =>
                            _fadeRoute(const PaymentsReportView()),
                  ),
                  GoRoute(
                    path: 'features',
                    pageBuilder:
                        (context, state) =>
                            _fadeRoute(const FeaturesView()),
                  ),
                  GoRoute(
                    path: 'audit-logs',
                    pageBuilder:
                        (context, state) =>
                            _fadeRoute(const AuditLogsView()),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RouterName.sell,
                pageBuilder:
                    (context, state) => _fadeRoute(const SellView()),
                redirect: (context, state) {
                  ref
                      .read(navigationProvider.notifier)
                      .setCurrentPage(RouterName.sell);
                  return null;
                },
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RouterName.salesHistory,
                pageBuilder:
                    (context, state) => _fadeRoute(const SalesHistoryView()),
                redirect: (context, state) {
                  ref
                      .read(navigationProvider.notifier)
                      .setCurrentPage(RouterName.salesHistory);
                  return null;
                },
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RouterName.expenses,
                pageBuilder:
                    (context, state) => _fadeRoute(const ExpensesView()),
                redirect: (context, state) {
                  ref
                      .read(navigationProvider.notifier)
                      .setCurrentPage(RouterName.expenses);
                  return null;
                },
              ),
            ],
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
