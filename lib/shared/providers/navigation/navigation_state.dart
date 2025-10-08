class NavigationState {
  final String currentPage;
  final bool isMenuOpen;
  final bool isAuthenticated;
  final bool isAdmin;

  const NavigationState({
    this.currentPage = '/',
    this.isMenuOpen = false,
    this.isAuthenticated = false,
    this.isAdmin = false,
  });

  NavigationState copyWith({
    String? currentPage,
    bool? isMenuOpen,
    bool? isAuthenticated,
    bool? isAdmin,
  }) {
    return NavigationState(
      currentPage: currentPage ?? this.currentPage,
      isMenuOpen: isMenuOpen ?? this.isMenuOpen,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      isAdmin: isAdmin ?? this.isAdmin,
    );
  }
}
