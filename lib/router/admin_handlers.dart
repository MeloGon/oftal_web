import 'package:fluro/fluro.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:oftal_web/shared/providers/auth/auth_provider.dart';
import 'package:oftal_web/shared/providers/auth/auth_state.dart';

class AdminHandlers {
  static Handler login = Handler(
    handlerFunc: (context, params) {
      final container = ProviderScope.containerOf(context!);
      final authState = container.read(authProvider);
      if (authState.status == AuthStatus.authenticated) {
        // TODO: aqui ira al login
        return const SizedBox();
      } else {
        // TODO: aqui ira al dashboard
        return const SizedBox();
      }
    },
  );
}
