import 'package:flutter/material.dart';
import 'package:fluro/fluro.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:oftal_web/shared/providers/providers.dart';

class DashboardHandlers {
  static Handler dashboard = Handler(
    handlerFunc: (context, params) {
      final container = ProviderScope.containerOf(context!);
      final authState = container.read(authProvider);
      if (authState.status == AuthStatus.authenticated) {
        //mostrar el dashboard
        return const SizedBox();
      } else {
        //mostrar el login
        return const SizedBox();
      }
    },
  );
}
