class AppFeaturesState {
  const AppFeaturesState({
    this.changeDateEnabled = true,
    this.isLoading = false,
  });

  final bool changeDateEnabled;
  final bool isLoading;

  AppFeaturesState copyWith({
    bool? changeDateEnabled,
    bool? isLoading,
  }) {
    return AppFeaturesState(
      changeDateEnabled: changeDateEnabled ?? this.changeDateEnabled,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}
