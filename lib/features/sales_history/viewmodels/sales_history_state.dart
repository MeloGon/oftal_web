import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:oftal_web/core/enums/enums.dart';
import 'package:oftal_web/shared/models/shared_models.dart';

part 'sales_history_state.freezed.dart';

@freezed
abstract class SalesHistoryState with _$SalesHistoryState {
  const factory SalesHistoryState({
    @Default(false) bool isLoading,
    @Default([]) List<SalesModel> sales,
    SalesModel? saleSelectedForDetails,
    @Default([]) List<SalesDetailsModel> saleDetails,
    SnackbarConfigModel? snackbarConfig,
    @Default('') String errorMessage,
    @Default(20) int rowsPerPage,
    FilterToSalesHistory? selectedFilter,
    @Default(false) bool isEditSaleDialogOpen,
    SalesModel? saleToEdit,
  }) = _SalesHistoryState;
}
