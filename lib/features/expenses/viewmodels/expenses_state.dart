import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:oftal_web/shared/models/shared_models.dart';

part 'expenses_state.freezed.dart';

@freezed
abstract class ExpensesState with _$ExpensesState {
  const factory ExpensesState({
    @Default(false) bool isLoading,
    @Default('') String errorMessage,
    @Default(<ExpenseModel>[]) List<ExpenseModel> expenses,
    @Default(<ExpenseCategoryModel>[]) List<ExpenseCategoryModel> categories,
    @Default(20) int rowsPerPage,
    SnackbarConfigModel? snackbarConfig,
  }) = _ExpensesState;
}
