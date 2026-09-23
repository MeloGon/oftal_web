import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:oftal_web/core/enums/enums.dart';
import 'package:oftal_web/features/sales_history/viewmodels/sales_history_provider.dart';
import 'package:oftal_web/features/settings/viewmodels/app_features_provider.dart';
import 'package:oftal_web/features/sales_history/views/widgets/filter_history_sales.dart';
import 'package:oftal_web/features/sales_history/views/widgets/sale_history_tile.dart';
import 'package:oftal_web/features/sales_history/views/widgets/sales_details_dialog.dart';
import 'package:oftal_web/features/sales_history/views/widgets/sales_history_page_header.dart';
import 'package:oftal_web/shared/extensions/extensions.dart';
import 'package:oftal_web/shared/models/shared_models.dart';
import 'package:oftal_web/shared/widgets/widgets.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class SalesHistoryView extends ConsumerStatefulWidget {
  const SalesHistoryView({super.key});

  @override
  ConsumerState<SalesHistoryView> createState() => _SalesHistoryViewState();
}

class _SalesHistoryViewState extends ConsumerState<SalesHistoryView> {
  @override
  void initState() {
    super.initState();
    if (ref.read(salesHistoryProvider).sales.isEmpty) {
      Future.microtask(
        () => ref.read(salesHistoryProvider.notifier).getSales(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final salesState = ref.watch(salesHistoryProvider);
    final salesNotifier = ref.read(salesHistoryProvider.notifier);
    final changeDateEnabled = ref.watch(
      appFeaturesProvider.select((s) => s.changeDateEnabled),
    );

    ref.listenLoading(
      salesHistoryProvider.select((s) => s.isLoading),
      context,
      onHidden: () {
        final state = ref.read(salesHistoryProvider);
        if (state.saleSelectedForDetails != null) {
          SalesDetailsDialog().show(
            context,
            state.saleDetails,
            state.saleSelectedForDetails!,
            ref,
          );
        }
      },
    );

    ref.listen(salesHistoryProvider, (previous, next) {
      if (next.errorMessage.isNotEmpty &&
          previous?.errorMessage != next.errorMessage) {
        _showSnackbar(context, next.snackbarConfig, next.errorMessage);
        Future.microtask(
          () => ref.read(salesHistoryProvider.notifier).clearErrorMessage(),
        );
      }
    });

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 16,
        children: [
          // ─── Page header + actions ────────────────────────
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Expanded(child: SalesHistoryPageHeader()),
              ShadButton.outline(
                size: ShadButtonSize.sm,
                onPressed:
                    () => salesNotifier.exportPatientsToCsv(salesState.sales),
                child: const Row(
                  spacing: 6,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(LucideIcons.fileDown, size: 14),
                    Text('Exportar CSV'),
                  ],
                ),
              ),
            ],
          ),

          // ─── Filters card ─────────────────────────────────
          ShadCard(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Expanded(child: FilterHistorySales()),
              ],
            ),
          ),

          // ─── List ─────────────────────────────────────────
          Expanded(
            child: PagedListCard<SalesModel>(
              items: salesState.sales,
              emptyLabel: 'Sin ventas',
              emptyIcon: Icons.point_of_sale_outlined,
              itemBuilder: (_, sale) => SaleHistoryTile(
                sale: sale,
                changeDateEnabled: changeDateEnabled,
              ),
            ),
          ),

          // ─── Pagination ───────────────────────────────────
          ListPaginationBar(
            label: 'Página ${salesState.pageNumber}',
            canPrev: salesState.offset > 0 && !salesState.isLoading,
            canNext: salesState.hasMore && !salesState.isLoading,
            onPrev: salesNotifier.prevPage,
            onNext: salesNotifier.nextPage,
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
