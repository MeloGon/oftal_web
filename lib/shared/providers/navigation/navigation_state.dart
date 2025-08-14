class NavigationState {
  final String currentPage;
  final bool isMenuOpen;
  final bool isAuthenticated;

  const NavigationState({
    this.currentPage = '/',
    this.isMenuOpen = false,
    this.isAuthenticated = false,
  });

  NavigationState copyWith({
    String? currentPage,
    bool? isMenuOpen,
    bool? isAuthenticated,
  }) {
    return NavigationState(
      currentPage: currentPage ?? this.currentPage,
      isMenuOpen: isMenuOpen ?? this.isMenuOpen,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
    );
  }
}
