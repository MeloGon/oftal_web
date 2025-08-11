import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:oftal_web/core/constants/app_strings.dart';
import 'package:oftal_web/features/login/pages/login_view.dart';
import 'package:oftal_web/router/app_router.dart';
import 'package:oftal_web/shared/layouts/layouts.dart';
import 'package:oftal_web/shared/providers/providers.dart';
import 'package:oftal_web/shared/services/navigation_service.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

void main() {
  Flurorouter.configureRoutes();
  runApp(const ProviderScope(child: MainApp()));
}

class MainApp extends ConsumerWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ShadApp(
      theme: ShadThemeData(
        brightness: Brightness.light,
        colorScheme: const ShadZincColorScheme.light(),
        textTheme: ShadTextTheme.fromGoogleFont(
          GoogleFonts.poppins,
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
          return const LoginView();
        } else {
          return AuthLayout(child: child!);
        }
      },
    );
  }
}
