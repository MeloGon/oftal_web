import 'package:oftal_web/shared/providers/navigation/navigation_state.dart';
import 'package:oftal_web/shared/services/local_storage.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'navigation_provider.g.dart';

@riverpod
class Navigation extends _$Navigation {
  @override
  NavigationState build() {
    Future.microtask(() {
      isAdmin();
    });
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

  Future<void> isAdmin() async {
    final profile = await LocalStorage.getProfile();
    state = state.copyWith(isAdmin: profile.role == 'admin');
  }
}
