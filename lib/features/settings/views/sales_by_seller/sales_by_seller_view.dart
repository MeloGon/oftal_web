import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:oftal_web/core/enums/snackbar_enum.dart';
import 'package:oftal_web/core/theme/app_colors.dart';
import 'package:oftal_web/features/settings/viewmodels/sales_by_seller_provider.dart';
import 'package:oftal_web/shared/extensions/extensions.dart';
import 'package:oftal_web/shared/models/sales_model.dart';
import 'package:oftal_web/shared/models/snackbar_config_model.dart';
import 'package:oftal_web/shared/widgets/widgets.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import 'widgets/commissions_dialog.dart';
import 'widgets/filter_bar.dart';
import 'widgets/seller_section.dart';

class SalesBySellerView extends ConsumerWidget {
  const SalesBySellerView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(salesBySellerProvider);
    final notifier = ref.read(salesBySellerProvider.notifier);

    ref.listenLoading(
      salesBySellerProvider.select((s) => s.isLoading),
      context,
    );

    ref.listen(salesBySellerProvider, (previous, next) {
      if (next.errorMessage.isNotEmpty &&
          previous?.errorMessage != next.errorMessage) {
        CustomSnackbar().show(
          context,
          next.snackbarConfig ??
              SnackbarConfigModel(title: 'Error', type: SnackbarEnum.error),
          next.errorMessage,
        );
        Future.microtask(notifier.clearErrorMessage);
      }
    });

    final allSellers = state.availableSellers;
    final allBySeller = _groupBySeller(state.sales);
    final bySeller = Map.of(allBySeller)
      ..removeWhere((seller, _) => !state.isSellerActive(seller));

    final sellerTotals = Map.fromEntries(
      allBySeller.entries.map((e) => MapEntry(
        e.key,
        e.value.fold<double>(
          0,
          (sum, s) => sum + (s.totalWithDiscount ?? s.total ?? 0),
        ),
      )),
    );

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 20,
        children: [
          // ─── Header ──────────────────────────────────────────
          Row(
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
                      'Reportes \u00b7 Ventas por vendedor',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: AppColors.zinc900,
                      ),
                    ),
                    Text(
                      'Ventas agrupadas por vendedor seg\u00fan el mes seleccionado',
                      style: TextStyle(fontSize: 12, color: AppColors.zinc500),
                    ),
                  ],
                ),
              ),
              if (sellerTotals.isNotEmpty)
                ShadButton.outline(
                  onPressed: () => showDialog(
                    context: context,
                    builder: (_) => CommissionsDialog(
                      sellerTotals: sellerTotals,
                    ),
                  ),
                  child: const Row(
                    spacing: 8,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.calculate_outlined, size: 16),
                      Text('C\u00e1lculo de comisiones'),
                    ],
                  ),
                ),
            ],
          ),

          // ─── Filter bar ───────────────────────────────────────
          FilterBar(
            selectedMonth: state.selectedMonth,
            onMonthPicked: notifier.selectMonth,
            sellers: allSellers,
            sellerCounts: Map.fromEntries(
              allSellers.map((s) => MapEntry(s, allBySeller[s]?.length ?? 0)),
            ),
            isSellerActive: state.isSellerActive,
            onToggleSeller: notifier.toggleSeller,
            onSelectAll: notifier.selectAllSellers,
            allActive: state.selectedSellers == null,
          ),

          // ─── Content ──────────────────────────────────────────
          Expanded(
            child: SingleChildScrollView(
              child: bySeller.isEmpty && !state.isLoading
                  ? const EmptyState(label: 'Sin ventas en el período seleccionado')
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: 24,
                      children: bySeller.entries.map((entry) {
                        return SellerSection(
                          sellerName: entry.key,
                          sales: entry.value,
                        );
                      }).toList(),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Map<String, List<SalesModel>> _groupBySeller(List<SalesModel> sales) {
    final map = <String, List<SalesModel>>{};
    for (final sale in sales) {
      final raw = sale.authorName?.trim() ?? '';
      final key = raw.isNotEmpty ? _toTitleCase(raw) : 'Sin vendedor';
      map.putIfAbsent(key, () => []).add(sale);
    }
    return Map.fromEntries(
      map.entries.toList()..sort((a, b) => a.key.compareTo(b.key)),
    );
  }

  static String _toTitleCase(String name) {
    return name.split(' ').map((w) {
      if (w.isEmpty) return w;
      return w[0].toUpperCase() + w.substring(1).toLowerCase();
    }).join(' ');
  }
}
