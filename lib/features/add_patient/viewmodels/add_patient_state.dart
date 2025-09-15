class AddPatientState {
  final bool isLoading;
  final String errorMessage;

  AddPatientState({
    this.isLoading = false,
    this.errorMessage = '',
  });

  AddPatientState copyWith({
    bool? isLoading,
    String? errorMessage,
  }) {
    return AddPatientState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
