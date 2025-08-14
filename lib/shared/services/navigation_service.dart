import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:oftal_web/shared/providers/providers.dart';

class NavigationService {
  static GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  static navigateTo(String routeName) {
    navigatorKey.currentState?.pushNamed(routeName);
  }

  static navigateToWithData(String routeName, dynamic data) {
    navigatorKey.currentState?.pushNamed(routeName, arguments: data);
  }

  // Método para navegar y actualizar la página actual
  static void navigateAndUpdatePage(
    String routeName,
    String pageName,
    ProviderContainer container,
  ) {
    // Primero navegar
    navigatorKey.currentState?.pushNamed(routeName);

    // Luego actualizar la página actual de forma segura
    Future.microtask(() {
      final currentPageNotifier = container.read(navigationProvider.notifier);
      currentPageNotifier.setCurrentPage(pageName);
    });
  }

  // Método para reemplazar y actualizar la página actual
  static void replaceAndUpdatePage(
    String routeName,
    String pageName,
    ProviderContainer container,
  ) {
    // Primero reemplazar
    navigatorKey.currentState?.pushReplacementNamed(routeName);

    // Luego actualizar la página actual de forma segura
    Future.microtask(() {
      final currentPageNotifier = container.read(navigationProvider.notifier);
      currentPageNotifier.setCurrentPage(pageName);
    });
  }
}
