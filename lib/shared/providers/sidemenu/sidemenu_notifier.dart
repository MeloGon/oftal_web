import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:oftal_web/shared/providers/sidemenu/sidemenu_state.dart';

class SideMenuNotifier extends StateNotifier<SideMenuState> {
  SideMenuNotifier({
    required TickerProvider vsync,
    Duration duration = const Duration(milliseconds: 250),
    Curve curve = Curves.easeInOut,
  }) : super(const SideMenuState()) {
    _menuController = AnimationController(vsync: vsync, duration: duration);
    movement = Tween<double>(
      begin: -200,
      end: 0,
    ).animate(CurvedAnimation(parent: _menuController, curve: curve));
    opacity = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _menuController, curve: curve));
  }

  late final AnimationController _menuController;
  late final Animation<double> movement;
  late final Animation<double> opacity;

  AnimationController get controller => _menuController;

  void setCurrentPageUrl(String routeName) {
    state = state.copyWith(currentPage: routeName);
    // Igual que tu delay para “notificar” después
    Future.delayed(const Duration(milliseconds: 100), () {});
  }

  void openMenu() {
    if (!state.isOpen) {
      state = state.copyWith(isOpen: true);
      _menuController.forward();
    }
  }

  void closeMenu() {
    if (state.isOpen) {
      state = state.copyWith(isOpen: false);
      _menuController.reverse();
    }
  }

  void toggleMenu() {
    state.isOpen ? closeMenu() : openMenu();
  }

  @override
  void dispose() {
    _menuController.dispose();
    super.dispose();
  }
}
