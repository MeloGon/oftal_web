import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:oftal_web/core/enums/enums.dart';
import 'package:oftal_web/shared/models/daily_payment_model.dart';
import 'package:oftal_web/shared/models/snackbar_config_model.dart';

part 'payments_report_state.freezed.dart';

@freezed
abstract class PaymentsReportState with _$PaymentsReportState {
  const factory PaymentsReportState({
    @Default(false) bool isLoading,
    @Default([]) List<DailyPaymentModel> payments,
    @Default(ReportPeriodFilter.day) ReportPeriodFilter filter,
    required DateTime selectedDay,
    required DateTime selectedMonth,
    required DateTime rangeStart,
    required DateTime rangeEnd,
    @Default('') String errorMessage,
    SnackbarConfigModel? snackbarConfig,
  }) = _PaymentsReportState;
}
