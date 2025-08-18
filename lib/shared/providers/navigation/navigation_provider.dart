import 'package:oftal_web/shared/providers/navigation/navigation_state.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'navigation_provider.g.dart';

@riverpod
class Navigation extends _$Navigation {
  @override
  NavigationState build() {
    return NavigationState();
  }

  void openMenu() {
    state = state.copyWith(isMenuOpen: true);
  }

  void closeMenu() {
    state = state.copyWith(isMenuOpen: false);
  }

  void toggleMenu() {
    state.isMenuOpen ? closeMenu() : openMenu();
  }

  void setCurrentPage(String page) {
    state = state.copyWith(currentPage: page);
  }
}
