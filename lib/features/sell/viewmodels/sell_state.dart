import 'package:flutter/material.dart';
import 'package:oftal_web/core/enums/enums.dart';
import 'package:oftal_web/shared/models/shared_models.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class SellState {
  final bool isLoading;
  final String errorMessage;
  final List<PatientModel> patients;
  final PatientModel? selectedPatient;
  final SellItemOptionsEnum? selectedItemOption;
  final PatientModel? patientToSell;
  final List<ReviewModel> reviews;
  final List<MountModel> mounts;
  SnackbarConfigModel? snackbarConfig;
  OptionsToSellEnum? selectedOptionToSell;
  final List<SalesDetailsModel> itemsToSell;
  final String idRemisionAndFolioSale;
  final DiscountReasonEnum? selectedDiscountReason;
  final List<ResinModel> resins;
  final int rowsPerPage;
  final GlobalKey<ShadFormState>? formKey;

  SellState({
    this.isLoading = false,
    this.errorMessage = '',
    this.patients = const [],
    this.selectedPatient,
    this.patientToSell,
    this.selectedItemOption,
    this.reviews = const [],
    this.mounts = const [],
    this.snackbarConfig,
    this.selectedOptionToSell,
    this.itemsToSell = const [],
    this.idRemisionAndFolioSale = '',
    this.selectedDiscountReason,
    this.resins = const [],
    this.rowsPerPage = 5,
    this.formKey,
  });

  SellState copyWith({
    bool? isLoading,
    String? errorMessage,
    List<PatientModel>? patients,
    PatientModel? selectedPatient,
    PatientModel? patientToSell,
    SellItemOptionsEnum? selectedItemOption,
    List<ReviewModel>? reviews,
    List<MountModel>? mounts,
    SnackbarConfigModel? snackbarConfig,
    OptionsToSellEnum? selectedOptionToSell,
    List<SalesDetailsModel>? itemsToSell,
    String? idRemisionAndFolioSale,
    DiscountReasonEnum? selectedDiscountReason,
    List<ResinModel>? resins,
    int? rowsPerPage,
    GlobalKey<ShadFormState>? formKey,
  }) {
    return SellState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      patients: patients ?? this.patients,
      selectedPatient: selectedPatient ?? this.selectedPatient,
      patientToSell: patientToSell ?? this.patientToSell,
      selectedItemOption: selectedItemOption ?? this.selectedItemOption,
      reviews: reviews ?? this.reviews,
      mounts: mounts ?? this.mounts,
      snackbarConfig: snackbarConfig ?? this.snackbarConfig,
      selectedOptionToSell: selectedOptionToSell ?? this.selectedOptionToSell,
      itemsToSell: itemsToSell ?? this.itemsToSell,
      idRemisionAndFolioSale:
          idRemisionAndFolioSale ?? this.idRemisionAndFolioSale,
      selectedDiscountReason:
          selectedDiscountReason ?? this.selectedDiscountReason,
      resins: resins ?? this.resins,
      rowsPerPage: rowsPerPage ?? this.rowsPerPage,
      formKey: formKey ?? this.formKey,
    );
  }
}
