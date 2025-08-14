import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:oftal_web/shared/providers/navigation/navigation_provider.dart';

class AppRouterService {
  // Método para actualizar la página actual de forma segura
  static void updateCurrentPage(ProviderContainer container, String page) {
    container.read(navigationProvider.notifier).setCurrentPage(page);
  }

  // Método para navegar y actualizar el estado
  static void navigateTo(
    BuildContext context,
    String route,
    ProviderContainer container,
  ) {
    // Primero navegar
    Navigator.pushNamed(context, route);

    // Luego actualizar el estado de forma segura
    updateCurrentPage(container, route);
  }

  // Método para reemplazar y actualizar el estado
  static void replaceTo(
    BuildContext context,
    String route,
    ProviderContainer container,
  ) {
    // Primero reemplazar
    Navigator.pushReplacementNamed(context, route);

    // Luego actualizar el estado de forma segura
    updateCurrentPage(container, route);
  }

  // Método para manejar la autenticación
  static void updateAuthStatus(
    ProviderContainer container,
    bool isAuthenticated,
  ) {
    container
        .read(navigationProvider.notifier)
        .setAuthenticationStatus(isAuthenticated);
  }
}
