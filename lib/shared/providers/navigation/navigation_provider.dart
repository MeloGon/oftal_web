import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:oftal_web/shared/providers/navigation/navigation_notifier.dart';
import 'package:oftal_web/shared/providers/navigation/navigation_state.dart';

// Provider principal para la navegación
final navigationProvider =
    StateNotifierProvider<NavigationNotifier, NavigationState>(
      (ref) => NavigationNotifier(),
    );

// Providers específicos para acceder fácilmente a partes del estado
final currentPageProvider = Provider<String>((ref) {
  return ref.watch(navigationProvider).currentPage;
});

final isMenuOpenProvider = Provider<bool>((ref) {
  return ref.watch(navigationProvider).isMenuOpen;
});

final isAuthenticatedProvider = Provider<bool>((ref) {
  return ref.watch(navigationProvider).isAuthenticated;
});
