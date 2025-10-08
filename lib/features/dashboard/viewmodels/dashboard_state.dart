class DashboardState {
  final bool isLoading;
  final String errorMessage;
  final int salesToday;
  final int clientsByBranch;

  DashboardState({
    this.isLoading = false,
    this.errorMessage = '',
    this.salesToday = 0,
    this.clientsByBranch = 0,
  });

  DashboardState copyWith({
    bool? isLoading,
    String? errorMessage,
    int? salesToday,
    int? clientsByBranch,
  }) {
    return DashboardState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      salesToday: salesToday ?? this.salesToday,
      clientsByBranch: clientsByBranch ?? this.clientsByBranch,
    );
  }
}
