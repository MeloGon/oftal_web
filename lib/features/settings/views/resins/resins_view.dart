import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:oftal_web/core/theme/app_colors.dart';
import 'package:oftal_web/core/enums/enums.dart';
import 'package:oftal_web/features/settings/viewmodels/resins/resins_provider.dart';
import 'package:oftal_web/features/settings/views/resins/widgets/add_resin_dialog.dart';
import 'package:oftal_web/features/settings/views/resins/widgets/resin_inventory_tile.dart';
import 'package:oftal_web/shared/models/shared_models.dart';
import 'package:oftal_web/shared/widgets/widgets.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class ResinsView extends ConsumerWidget {
  const ResinsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final resinsState = ref.watch(resinsProvider);
    final resinsNotifier = ref.read(resinsProvider.notifier);

    ref.listen(resinsProvider, (previous, next) {
      if (next.isAddResinDialogOpen &&
          previous?.isAddResinDialogOpen != next.isAddResinDialogOpen) {
        if (context.mounted) {
          AddResinDialog().show(context, ref).then((_) {
            ref.read(resinsProvider.notifier).closeAddResinDialog();
          });
        }
      }
      if (next.errorMessage.isNotEmpty &&
          previous?.errorMessage != next.errorMessage) {
        _showSnackbar(context, next.snackbarConfig, next.errorMessage);
        Future.microtask(
          () => ref.read(resinsProvider.notifier).clearErrorMessage(),
        );
      }
    });

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 20,
        children: [
          // ─── Page header ─────────────────────────────────
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              IconButton(
                onPressed: () => context.pop(),
                icon: const Icon(Icons.arrow_back_ios_rounded, size: 16),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.white,
                  side: const BorderSide(color: AppColors.zinc200),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 2,
                  children: [
                    Text(
                      'Inventario · Resinas',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: AppColors.zinc900,
                      ),
                    ),
                    Text(
                      'Gestiona el catálogo de resinas y lentes',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.zinc500,
                      ),
                    ),
                  ],
                ),
              ),
              ShadButton(
                onPressed: resinsNotifier.openAddResinDialog,
                child: const Row(
                  spacing: 6,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.add, size: 16),
                    Text('Añadir resina'),
                  ],
                ),
              ),
            ],
          ),

          // ─── List ─────────────────────────────────────────
          Expanded(
            child: PagedListCard<ResinModel>(
              items: resinsState.resins,
              isLoading: resinsState.isLoading,
              emptyLabel: 'Sin resinas registradas',
              emptyIcon: Icons.lens_outlined,
              itemBuilder: (_, r) => ResinInventoryTile(resin: r),
            ),
          ),
          ListPaginationBar(
            label: 'Página ${resinsState.offset ~/ resinsState.rowsPerPage + 1}',
            canPrev: resinsState.offset > 0 && !resinsState.isLoading,
            canNext: resinsState.hasMore && !resinsState.isLoading,
            onPrev: () => resinsNotifier.fetchPage(
              offset: (resinsState.offset - resinsState.rowsPerPage)
                  .clamp(0, 1 << 31),
              limit: resinsState.rowsPerPage,
            ),
            onNext: () => resinsNotifier.fetchPage(
              offset: resinsState.offset + resinsState.rowsPerPage,
              limit: resinsState.rowsPerPage,
            ),
            pageSizes: const [10, 20, 30, 50],
            pageSize: resinsState.rowsPerPage,
            onPageSizeChanged: resinsNotifier.changeRowsPerPage,
          ),
        ],
      ),
    );
  }
}

void _showSnackbar(
  BuildContext context,
  SnackbarConfigModel? snackbarConfig,
  String errorMessage,
) {
  CustomSnackbar().show(
    context,
    snackbarConfig ??
        SnackbarConfigModel(title: 'Error', type: SnackbarEnum.error),
    errorMessage,
  );
}
