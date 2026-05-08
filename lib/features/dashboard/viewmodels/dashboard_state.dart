import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:oftal_web/shared/models/shared_models.dart';

part 'dashboard_state.freezed.dart';

@freezed
abstract class DashboardState with _$DashboardState {
  const factory DashboardState({
    @Default(false) bool isLoading,
    @Default('') String errorMessage,
    @Default(0) int salesToday,
    @Default(0) int clientsByBranch,
    @Default('') String branchName,
    @Default('') String userName,
    @Default(0.0) double incomeToday,
    @Default(<SalesModel>[]) List<SalesModel> recentSales,
    @Default(<String, int>{}) Map<String, int> salesByDay,
    @Default(<String, double>{}) Map<String, double> paymentsByMethod,
  }) = _DashboardState;
}
