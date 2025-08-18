import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:oftal_web/router/app_router.dart';
import 'package:oftal_web/shared/providers/auth_general/auth_provider.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:oftal_web/shared/services/local_storage.dart';

void main() async {
  GoRouter.optionURLReflectsImperativeAPIs = true;
  WidgetsFlutterBinding.ensureInitialized();
  await LocalStorage.init();

  runApp(
    ProviderScope(
      child: const MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    ref.watch(authProvider);
    return ShadApp.router(
      routerConfig: router,
      theme: ShadThemeData(
        colorScheme: ShadZincColorScheme.light(),
        textTheme: ShadTextTheme.fromGoogleFont(GoogleFonts.sofiaSans),
        brightness: Brightness.light,
      ),
      // builder: (_, child) {
      //   return AuthLayout(child: child!);
      // },
    );
  }
}
