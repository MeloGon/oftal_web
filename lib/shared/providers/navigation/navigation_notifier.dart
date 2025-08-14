import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:oftal_web/shared/providers/navigation/navigation_state.dart';

class NavigationNotifier extends StateNotifier<NavigationState> {
  NavigationNotifier() : super(const NavigationState());

  // Métodos para la página actual
  void setCurrentPage(String page) {
    state = state.copyWith(currentPage: page);
  }

  // Métodos para el menú
  void openMenu() {
    if (!state.isMenuOpen) {
      state = state.copyWith(isMenuOpen: true);
    }
  }

  void closeMenu() {
    if (state.isMenuOpen) {
      state = state.copyWith(isMenuOpen: false);
    }
  }

  void toggleMenu() {
    state = state.copyWith(isMenuOpen: !state.isMenuOpen);
  }

  // Método para autenticación
  void setAuthenticationStatus(bool isAuthenticated) {
    state = state.copyWith(isAuthenticated: isAuthenticated);
  }

  // Método para navegar a una página
  void navigateTo(String page) {
    setCurrentPage(page);
    closeMenu(); // Cerrar menú al navegar
  }
}
