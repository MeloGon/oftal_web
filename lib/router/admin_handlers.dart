import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:oftal_web/features/login/views/login_view.dart';
import 'package:oftal_web/shared/providers/auth_general/auth_provider.dart';
import 'package:oftal_web/shared/providers/auth_general/auth_state.dart';
import 'package:oftal_web/shared/views/dashboard_view.dart';

class AdminHandlers {
  static Handler login = Handler(
    handlerFunc: (context, params) {
      final container = ProviderScope.containerOf(context!);
      final authState = container.read(authProvider);
      if (authState.status == AuthStatus.notAuthenticated) {
        return const LoginView();
        // return const DashboardView();
      } else {
        // TODO: aqui ira al dashboard
        return const SizedBox();
      }
    },
  );
}
