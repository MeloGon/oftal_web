import 'package:oftal_web/shared/models/sales_model.dart';
import 'package:oftal_web/shared/models/snackbar_config_model.dart';

class SalesBySellerState {
  final bool isLoading;
  final List<SalesModel> sales;
  final DateTime selectedMonth;
  final String errorMessage;
  final SnackbarConfigModel? snackbarConfig;
  // null = all sellers selected (default); non-null = explicit selection
  final Set<String>? selectedSellers;

  const SalesBySellerState({
    this.isLoading = false,
    this.sales = const [],
    required this.selectedMonth,
    this.errorMessage = '',
    this.snackbarConfig,
    this.selectedSellers,
  });

  /// All unique seller names present in [sales], sorted (normalized to title case).
  List<String> get availableSellers {
    return sales
        .map((s) => s.authorName?.trim().isNotEmpty == true
            ? _toTitleCase(s.authorName!.trim())
            : 'Sin vendedor')
        .toSet()
        .toList()
      ..sort();
  }

  static String _toTitleCase(String name) {
    return name.split(' ').map((w) {
      if (w.isEmpty) return w;
      return w[0].toUpperCase() + w.substring(1).toLowerCase();
    }).join(' ');
  }

  /// Whether [seller] is currently active in the filter.
  bool isSellerActive(String seller) =>
      selectedSellers == null || selectedSellers!.contains(seller);

  SalesBySellerState copyWith({
    bool? isLoading,
    List<SalesModel>? sales,
    DateTime? selectedMonth,
    String? errorMessage,
    SnackbarConfigModel? snackbarConfig,
    Set<String>? selectedSellers,
    bool clearSelectedSellers = false,
  }) {
    return SalesBySellerState(
      isLoading: isLoading ?? this.isLoading,
      sales: sales ?? this.sales,
      selectedMonth: selectedMonth ?? this.selectedMonth,
      errorMessage: errorMessage ?? this.errorMessage,
      snackbarConfig: snackbarConfig ?? this.snackbarConfig,
      selectedSellers:
          clearSelectedSellers ? null : (selectedSellers ?? this.selectedSellers),
    );
  }
}
