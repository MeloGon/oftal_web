import 'package:flutter/material.dart';
import 'package:fluro/fluro.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:oftal_web/features/add_patient/views/add_patient_view.dart';
import 'package:oftal_web/router/app_router.dart';
import 'package:oftal_web/shared/providers/providers.dart';
import 'package:oftal_web/shared/services/app_router_service.dart';

class DashboardHandlers {
  static Handler dashboard = Handler(
    handlerFunc: (context, params) {
      final container = ProviderScope.containerOf(context!);
      final authState = container.read(authProvider);

      // Usar el nuevo servicio de routing
      AppRouterService.updateCurrentPage(container, Flurorouter.dashboardRoute);

      if (authState.status == AuthStatus.authenticated) {
        return const SizedBox(); // Dashboard principal
      } else {
        return const SizedBox(); // Login
      }
    },
  );

  static Handler addPatient = Handler(
    handlerFunc: (context, params) {
      final container = ProviderScope.containerOf(context!);
      final authState = container.read(authProvider);

      // Usar el nuevo servicio de routing
      AppRouterService.updateCurrentPage(
        container,
        Flurorouter.addPatientRoute,
      );

      if (authState.status == AuthStatus.authenticated) {
        return const AddPatientView();
      } else {
        return const SizedBox(); // Login
      }
    },
  );
}
