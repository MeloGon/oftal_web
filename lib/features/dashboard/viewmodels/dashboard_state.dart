import 'package:freezed_annotation/freezed_annotation.dart';

part 'dashboard_state.freezed.dart';

@freezed
abstract class DashboardState with _$DashboardState {
  const factory DashboardState({
    @Default(false) bool isLoading,
    @Default('') String errorMessage,
    @Default(0) int salesToday,
    @Default(0) int clientsByBranch,
    @Default('') String branchName,
  }) = _DashboardState;
}
