class AddPatientState {
  final bool isLoading;
  final String errorMessage;
  final String? selectedGender;
  final String? selectedBranch;

  AddPatientState({
    this.isLoading = false,
    this.errorMessage = '',
    this.selectedGender,
    this.selectedBranch,
  });

  AddPatientState copyWith({
    bool? isLoading,
    String? errorMessage,
    String? selectedGender,
    String? selectedBranch,
  }) {
    return AddPatientState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      selectedGender: selectedGender ?? this.selectedGender,
      selectedBranch: selectedBranch ?? this.selectedBranch,
    );
  }
}
