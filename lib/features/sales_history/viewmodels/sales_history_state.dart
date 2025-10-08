import 'package:oftal_web/shared/models/shared_models.dart';

class SalesHistoryState {
  final bool isLoading;
  final List<SalesModel> sales;
  final SalesModel? saleSelectedForDetails;
  final List<SalesDetailsModel> saleDetails;
  SnackbarConfigModel? snackbarConfig;
  final String errorMessage;

  SalesHistoryState({
    this.isLoading = false,
    this.sales = const [],
    this.saleSelectedForDetails,
    this.saleDetails = const [],
    this.snackbarConfig,
    this.errorMessage = '',
  });

  SalesHistoryState copyWith({
    bool? isLoading,
    List<SalesModel>? sales,
    SalesModel? saleSelectedForDetails,
    List<SalesDetailsModel>? saleDetails,
    SnackbarConfigModel? snackbarConfig,
    String? errorMessage,
  }) {
    return SalesHistoryState(
      isLoading: isLoading ?? this.isLoading,
      sales: sales ?? this.sales,
      saleSelectedForDetails:
          saleSelectedForDetails ?? this.saleSelectedForDetails,
      saleDetails: saleDetails ?? this.saleDetails,
      snackbarConfig: snackbarConfig ?? this.snackbarConfig,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
