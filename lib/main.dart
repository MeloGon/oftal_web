import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:oftal_web/core/constants/app_strings.dart';
import 'package:oftal_web/features/login/views/login_view.dart';
import 'package:oftal_web/router/app_router.dart';
import 'package:oftal_web/shared/layouts/layouts.dart';
import 'package:oftal_web/shared/providers/providers.dart';
import 'package:oftal_web/shared/services/navigation_service.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

void main() {
  Flurorouter.configureRoutes();
  runApp(const ProviderScope(child: MainApp()));
}

class MainApp extends ConsumerStatefulWidget {
  const MainApp({super.key});

  @override
  ConsumerState<MainApp> createState() => _MainAppState();
}

class _MainAppState extends ConsumerState<MainApp> {
  @override
  void initState() {
    super.initState();
    // Sincronizar el estado de autenticación después de que se construya el widget
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _syncAuthStatus();
    });
  }

  void _syncAuthStatus() {
    final authState = ref.read(authProvider);
    final navigationNotifier = ref.read(navigationProvider.notifier);

    if (authState.status == AuthStatus.authenticated) {
      navigationNotifier.setAuthenticationStatus(true);
    } else {
      navigationNotifier.setAuthenticationStatus(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ShadApp(
      theme: ShadThemeData(
        brightness: Brightness.light,
        colorScheme: const ShadZincColorScheme.light(),
        textTheme: ShadTextTheme.fromGoogleFont(
          GoogleFonts.montserrat,
        ),
      ),
      debugShowCheckedModeBanner: false,
      title: AppStrings.appName,
      initialRoute: '/',
      navigatorKey: NavigationService.navigatorKey,
      onGenerateRoute: Flurorouter.router.generator,
      builder: (_, child) {
        final authState = ref.watch(authProvider);

        if (authState.status == AuthStatus.checking) {
          return const LoginView();
        }

        if (authState.status == AuthStatus.authenticated) {
          return DashboardLayout(child: child ?? const SizedBox());
        } else {
          return AuthLayout(child: child ?? const LoginView());
        }
      },
    );
  }
}
