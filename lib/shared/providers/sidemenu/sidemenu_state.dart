class SideMenuState {
  final bool isOpen;
  final String currentPage;

  const SideMenuState({
    this.isOpen = false,
    this.currentPage = '',
  });

  SideMenuState copyWith({
    bool? isOpen,
    String? currentPage,
  }) {
    return SideMenuState(
      isOpen: isOpen ?? this.isOpen,
      currentPage: currentPage ?? this.currentPage,
    );
  }
}
