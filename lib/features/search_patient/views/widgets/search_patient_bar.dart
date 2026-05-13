import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:oftal_web/features/search_patient/viewmodels/search_patient_provider.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class SearchPatientBar extends ConsumerWidget {
  const SearchPatientBar({super.key, required this.paginatorController});

  final PaginatorController paginatorController;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.watch(searchPatientProvider.notifier);

    void goToFirst() {
      if (paginatorController.isAttached) {
        paginatorController.goToFirstPage();
      }
    }

    return ShadCard(
      padding: const EdgeInsets.all(16),
      child: ShadInput(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
        placeholder: const Text('Buscar por nombre del paciente...'),
        controller: notifier.searchController,
        leading: const Icon(LucideIcons.search, size: 16),
        onSubmitted: (_) {
          notifier.getPatients();
          goToFirst();
        },
        trailing: notifier.searchIsEmpty
            ? null
            : ShadButton.ghost(
                height: 28,
                width: 28,
                padding: EdgeInsets.zero,
                onPressed: () {
                  notifier.searchController.clear();
                  notifier.getPatients();
                  goToFirst();
                },
                child: const Icon(LucideIcons.x, size: 14),
              ),
      ),
    );
  }
}
