import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:oftal_web/core/enums/enums.dart';
import 'package:oftal_web/features/search_patient/viewmodels/search_patient_provider.dart';
import 'package:oftal_web/features/search_patient/views/widgets/add_review_dialog.dart';
import 'package:oftal_web/features/search_patient/views/widgets/edit_patient_dialog.dart';
import 'package:oftal_web/features/search_patient/views/widgets/patients_empty_state.dart';
import 'package:oftal_web/features/search_patient/views/widgets/patients_table.dart';
import 'package:oftal_web/features/search_patient/views/widgets/review_details_dialog.dart';
import 'package:oftal_web/features/search_patient/views/widgets/search_patient_bar.dart';
import 'package:oftal_web/features/search_patient/views/widgets/search_patient_header.dart';
import 'package:oftal_web/shared/extensions/extensions.dart';
import 'package:oftal_web/shared/models/snackbar_config_model.dart';
import 'package:oftal_web/shared/widgets/custom_snackbar.dart';

class SearchPatientView extends ConsumerStatefulWidget {
  const SearchPatientView({super.key});

  @override
  ConsumerState<SearchPatientView> createState() => _SearchPatientViewState();
}

class _SearchPatientViewState extends ConsumerState<SearchPatientView> {
  final PaginatorController _paginatorController = PaginatorController();

  @override
  void dispose() {
    _paginatorController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final searchPatientState = ref.watch(searchPatientProvider);

    ref.listenLoading(
      searchPatientProvider.select((s) => s.isLoading),
      context,
    );

    ref.listen(searchPatientProvider, (previous, next) {
      if (next.errorMessage.isNotEmpty &&
          previous?.errorMessage != next.errorMessage) {
        CustomSnackbar().show(
          context,
          next.snackbarConfig ??
              SnackbarConfigModel(title: 'Error', type: SnackbarEnum.error),
          next.errorMessage,
        );
        Future.microtask(
          () => ref.read(searchPatientProvider.notifier).clearErrorMessage(),
        );
      }
      if (next.isAddViewMeasureDialogOpen &&
          previous?.isAddViewMeasureDialogOpen !=
              next.isAddViewMeasureDialogOpen) {
        if (context.mounted) {
          AddReviewDialog().show(context, ref).then((_) {
            ref
                .read(searchPatientProvider.notifier)
                .closeAddViewMeasureDialog();
          });
        }
      }
      if (next.isReviewDialogOpen && !(previous?.isReviewDialogOpen ?? false)) {
        if (context.mounted) {
          ref.read(searchPatientProvider.notifier).closeReviewDialog();
          ReviewDetailsDialog().show(context, next, ref);
        }
      }
      if (next.isEditDialogOpen && !(previous?.isEditDialogOpen ?? false)) {
        if (context.mounted && next.patientToEdit != null) {
          ref.read(searchPatientProvider.notifier).closeEditDialog();
          EditPatientDialog().show(context, ref, next.patientToEdit!);
        }
      }
    });

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 20,
        children: [
          const SearchPatientHeader(),
          SearchPatientBar(paginatorController: _paginatorController),
          if (searchPatientState.patients.isNotEmpty)
            PatientsTable(paginatorController: _paginatorController)
          else
            const PatientsEmptyState(),
        ],
      ),
    );
  }
}
