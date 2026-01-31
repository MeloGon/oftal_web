import 'package:oftal_web/core/enums/enums.dart';
import 'package:oftal_web/shared/models/shared_models.dart';

class SalesHistoryState {
  final bool isLoading;
  final List<SalesModel> sales;
  final SalesModel? saleSelectedForDetails;
  final List<SalesDetailsModel> saleDetails;
  SnackbarConfigModel? snackbarConfig;
  final String errorMessage;
  final int rowsPerPage;
  final FilterToSalesHistory? selectedFilter;

  SalesHistoryState({
    this.isLoading = false,
    this.sales = const [],
    this.saleSelectedForDetails,
    this.saleDetails = const [],
    this.snackbarConfig,
    this.errorMessage = '',
    this.rowsPerPage = 20,
    this.selectedFilter,
  });

  SalesHistoryState copyWith({
    bool? isLoading,
    List<SalesModel>? sales,
    SalesModel? saleSelectedForDetails,
    bool resetSaleSelectedForDetails = false,
    List<SalesDetailsModel>? saleDetails,
    SnackbarConfigModel? snackbarConfig,
    String? errorMessage,
    int? rowsPerPage,
    FilterToSalesHistory? selectedFilter,
  }) {
    return SalesHistoryState(
      isLoading: isLoading ?? this.isLoading,
      sales: sales ?? this.sales,
      saleSelectedForDetails:
          resetSaleSelectedForDetails
              ? null
              : (saleSelectedForDetails ?? this.saleSelectedForDetails),

      saleDetails: saleDetails ?? this.saleDetails,
      snackbarConfig: snackbarConfig ?? this.snackbarConfig,
      errorMessage: errorMessage ?? this.errorMessage,
      rowsPerPage: rowsPerPage ?? this.rowsPerPage,
      selectedFilter: selectedFilter ?? this.selectedFilter,
    );
  }
}
