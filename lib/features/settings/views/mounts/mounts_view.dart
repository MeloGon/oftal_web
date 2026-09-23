import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:oftal_web/core/theme/app_colors.dart';
import 'package:go_router/go_router.dart';
import 'package:oftal_web/core/enums/enums.dart';
import 'package:oftal_web/features/settings/viewmodels/mounts/mounts_provider.dart';
import 'package:oftal_web/features/settings/views/mounts/widgets/add_mount_dialog.dart';
import 'package:oftal_web/features/settings/views/mounts/widgets/mount_inventory_tile.dart';
import 'package:oftal_web/shared/models/shared_models.dart';
import 'package:oftal_web/shared/widgets/widgets.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class MountsView extends ConsumerWidget {
  const MountsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mountsState = ref.watch(mountsProvider);
    final mountsNotifier = ref.read(mountsProvider.notifier);

    ref.listen(mountsProvider, (previous, next) {
      if (next.isAddMountDialogOpen &&
          previous?.isAddMountDialogOpen != next.isAddMountDialogOpen) {
        if (context.mounted) {
          AddMountDialog().show(context, ref).then((_) {
            ref.read(mountsProvider.notifier).closeAddMountDialog();
          });
        }
      }
      if (next.errorMessage.isNotEmpty &&
          previous?.errorMessage != next.errorMessage) {
        _showSnackbar(context, next.snackbarConfig, next.errorMessage);
        Future.microtask(
          () => ref.read(mountsProvider.notifier).clearErrorMessage(),
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
                      'Inventario · Monturas',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: AppColors.zinc900,
                      ),
                    ),
                    Text(
                      'Gestiona el catálogo de armazones y monturas',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.zinc500,
                      ),
                    ),
                  ],
                ),
              ),
              ShadButton(
                onPressed: mountsNotifier.openAddMountDialog,
                child: const Row(
                  spacing: 6,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.add, size: 16),
                    Text('Añadir montura'),
                  ],
                ),
              ),
            ],
          ),

          // ─── Search bar ──────────────────────────────────
          Row(
            children: [
              Expanded(
                child: Material(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  child: ShadInput(
                    controller: mountsNotifier.searchController,
                    placeholder: const Text('Buscar por marca o modelo...'),
                    leading: const Padding(
                      padding: EdgeInsets.all(8),
                      child: Icon(Icons.search, size: 16, color: AppColors.zinc500),
                    ),
                    trailing: mountsState.isSearchMode
                        ? GestureDetector(
                            onTap: mountsNotifier.clearSearch,
                            child: const Padding(
                              padding: EdgeInsets.all(8),
                              child: Icon(Icons.close, size: 16, color: AppColors.zinc500),
                            ),
                          )
                        : null,
                    onSubmitted: (_) => mountsNotifier.searchMounts(),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              ShadButton.outline(
                onPressed: mountsNotifier.searchMounts,
                child: const Text('Buscar'),
              ),
            ],
          ),

          // ─── List ─────────────────────────────────────────
          if (mountsState.isSearchMode)
            Expanded(
              child: ClientPagedList<MountModel>(
                items: mountsState.mounts,
                pageSize: mountsState.rowsPerPage,
                isLoading: mountsState.isLoading,
                emptyLabel: 'Sin resultados',
                emptyIcon: Icons.search_off_rounded,
                itemBuilder: (_, m) => MountInventoryTile(mount: m),
              ),
            )
          else ...[
            Expanded(
              child: PagedListCard<MountModel>(
                items: mountsState.mounts,
                isLoading: mountsState.isLoading,
                emptyLabel: 'Sin monturas registradas',
                emptyIcon: Icons.visibility_outlined,
                itemBuilder: (_, m) => MountInventoryTile(mount: m),
              ),
            ),
            ListPaginationBar(
              label:
                  'Página ${mountsState.offset ~/ mountsState.rowsPerPage + 1}',
              canPrev: mountsState.offset > 0 && !mountsState.isLoading,
              canNext: mountsState.hasMore && !mountsState.isLoading,
              onPrev: () => mountsNotifier.fetchPage(
                offset: (mountsState.offset - mountsState.rowsPerPage)
                    .clamp(0, 1 << 31),
                limit: mountsState.rowsPerPage,
              ),
              onNext: () => mountsNotifier.fetchPage(
                offset: mountsState.offset + mountsState.rowsPerPage,
                limit: mountsState.rowsPerPage,
              ),
              pageSizes: const [10, 50, 100],
              pageSize: mountsState.rowsPerPage,
              onPageSizeChanged: mountsNotifier.changeRowsPerPage,
            ),
          ],
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
