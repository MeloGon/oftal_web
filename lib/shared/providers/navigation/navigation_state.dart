import 'package:freezed_annotation/freezed_annotation.dart';

part 'navigation_state.freezed.dart';

@freezed
abstract class NavigationState with _$NavigationState {
  const factory NavigationState({
    @Default('/') String currentPage,
    @Default(false) bool isMenuOpen,
    @Default(false) bool isAuthenticated,
    @Default(false) bool isAdmin,
  }) = _NavigationState;
}
