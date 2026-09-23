import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:oftal_web/core/enums/enums.dart';
import 'package:oftal_web/features/search_patient/viewmodels/search_patient_provider.dart';
import 'package:oftal_web/features/search_patient/views/widgets/add_review_dialog.dart';
import 'package:oftal_web/features/search_patient/views/widgets/edit_patient_dialog.dart';
import 'package:oftal_web/features/search_patient/views/widgets/patients_empty_state.dart';
import 'package:oftal_web/features/search_patient/views/widgets/patient_tile.dart';
import 'package:oftal_web/features/search_patient/views/widgets/review_details_dialog.dart';
import 'package:oftal_web/features/search_patient/views/widgets/search_patient_bar.dart';
import 'package:oftal_web/features/search_patient/views/widgets/search_patient_header.dart';
import 'package:oftal_web/shared/extensions/extensions.dart';
import 'package:oftal_web/shared/models/shared_models.dart';
import 'package:oftal_web/shared/widgets/widgets.dart';

class SearchPatientView extends ConsumerStatefulWidget {
  const SearchPatientView({super.key});

  @override
  ConsumerState<SearchPatientView> createState() => _SearchPatientViewState();
}

class _SearchPatientViewState extends ConsumerState<SearchPatientView> {
  @override
  Widget build(BuildContext context) {
    final searchPatientState = ref.watch(searchPatientProvider);
    final notifier = ref.read(searchPatientProvider.notifier);

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
          const SearchPatientBar(),
          if (searchPatientState.patients.isEmpty &&
              searchPatientState.offset == 0)
            const PatientsEmptyState()
          else ...[
            Expanded(
              child: PagedListCard<PatientModel>(
                items: searchPatientState.patients,
                emptyLabel: 'Sin pacientes',
                emptyIcon: Icons.people_outline,
                itemBuilder: (_, patient) => PatientTile(patient: patient),
              ),
            ),
            ListPaginationBar(
              label: 'Página ${searchPatientState.pageNumber}',
              canPrev: searchPatientState.offset > 0 &&
                  !searchPatientState.isLoading,
              canNext: searchPatientState.hasMore &&
                  !searchPatientState.isLoading,
              onPrev: notifier.prevPage,
              onNext: notifier.nextPage,
            ),
          ],
        ],
      ),
    );
  }
}
