import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:oftal_web/core/enums/enums.dart';
import 'package:oftal_web/shared/models/shared_models.dart';

part 'sell_state.freezed.dart';

@freezed
abstract class SellState with _$SellState {
  const factory SellState({
    @Default(false) bool isLoading,
    @Default('') String errorMessage,
    @Default([]) List<PatientModel> patients,
    PatientModel? selectedPatient,
    SellItemOptionsEnum? selectedItemOption,
    @Default([]) List<ReviewModel> reviews,
    @Default([]) List<MountModel> mounts,
    SnackbarConfigModel? snackbarConfig,
    OptionsToSellEnum? selectedOptionToSell,
    @Default([]) List<SalesDetailsModel> itemsToSell,
    @Default('') String idRemision,
    @Default('') String idFolio,
    DiscountReasonEnum? selectedDiscountReason,
    @Default([]) List<ResinModel> resins,
    @Default(5) int rowsPerPage,
    @Default([]) List<SellerModel> sellers,
    SellerModel? selectedSeller,
    PaymentMethodEnum? selectedInitialPaymentMethod,
  }) = _SellState;
}
