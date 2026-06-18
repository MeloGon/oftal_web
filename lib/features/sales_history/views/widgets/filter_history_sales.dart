import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:oftal_web/core/constants/constants.dart';
import 'package:oftal_web/core/enums/enums.dart';
import 'package:oftal_web/core/theme/app_text_styles.dart';
import 'package:oftal_web/features/sales_history/viewmodels/sales_history_provider.dart';
import 'package:oftal_web/features/sales_history/viewmodels/sellers_list_provider.dart';
import 'package:oftal_web/features/sales_history/views/widgets/pending_toggle.dart';
import 'package:oftal_web/shared/extensions/extensions.dart';
import 'package:oftal_web/shared/models/shared_models.dart';
import 'package:oftal_web/shared/widgets/widgets.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class FilterHistorySales extends ConsumerWidget {
  const FilterHistorySales({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final size = MediaQuery.of(context).size;
    final salesHistoryState = ref.watch(salesHistoryProvider);
    final salesHistoryNotifier = ref.read(salesHistoryProvider.notifier);
    final sellersAsync = ref.watch(sellersListProvider);
    return Wrap(
      spacing: 20,
      runSpacing: 10,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Filtrar por :', style: AppTextStyles(context).small13),
            const SizedBox(width: 10),
            ShadSelect<FilterToSalesHistory>(
              key: ValueKey(salesHistoryState.selectedFilter),
              placeholder: Text(AppStrings.select),
              initialValue: salesHistoryState.selectedFilter,
              selectedOptionBuilder: (context, value) => Text(value.label),
              options:
                  FilterToSalesHistory.values
                      .map((e) => ShadOption(value: e, child: Text(e.label)))
                      .toList(),
              onChanged: (value) {
                if (value != null) salesHistoryNotifier.selectFilter(value);
              },
            ).constrained(width: 200),
          ],
        ),
        if (salesHistoryState.selectedFilter == FilterToSalesHistory.patient ||
            salesHistoryState.selectedFilter == FilterToSalesHistory.folio)
          ShadInputFormField(
            padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 6),
            controller: salesHistoryNotifier.searchController,
            placeholder: Text(
              salesHistoryState.selectedFilter == FilterToSalesHistory.patient
                  ? 'Ingresa el nombre del paciente'
                  : 'Ingresa el numero de folio',
            ),
            onSubmitted: (_) => salesHistoryNotifier.getSales(),
            trailing: salesHistoryState.searchText.isEmpty
                ? null
                : ShadButton(
                    onPressed: () {
                      salesHistoryNotifier.searchController.clear();
                      salesHistoryNotifier.getSales();
                    },
                    child: const Icon(Icons.close),
                  ),
          ).constrained(
            width: size.width < 700 ? size.width - 48 : size.width * .48,
          ),
        if (salesHistoryState.selectedFilter == FilterToSalesHistory.seller)
          sellersAsync.when(
            loading: () => const SizedBox(
              width: 220,
              height: 36,
              child: Center(child: LinearProgressIndicator()),
            ),
            error: (_, _) => const SizedBox.shrink(),
            data: (sellers) {
              final selected = sellers.cast<SellerModel?>().firstWhere(
                (s) => s?.name == salesHistoryState.searchText,
                orElse: () => null,
              );
              return ShadSelect<SellerModel>(
                key: ValueKey(selected?.id),
                placeholder: const Text('Selecciona un vendedor'),
                initialValue: selected,
                selectedOptionBuilder: (context, value) => Text(value.name),
                options: sellers
                    .map((s) => ShadOption(value: s, child: Text(s.name)))
                    .toList(),
                onChanged: (seller) {
                  if (seller != null) {
                    salesHistoryNotifier.searchController.text = seller.name;
                    salesHistoryNotifier.getSales();
                  }
                },
              ).constrained(width: 220);
            },
          ),
        if (salesHistoryState.selectedFilter == FilterToSalesHistory.date)
          AppDatePickerButton(
            selectedDate: salesHistoryState.searchDate ?? DateTime.now(),
            lastDate: DateTime.now(),
            onDateSelected: salesHistoryNotifier.updateSearchDate,
          ),
        PendingToggle(
          active: salesHistoryState.onlyPending,
          onTap: salesHistoryNotifier.togglePending,
        ),
        if (salesHistoryState.selectedFilter != null ||
            salesHistoryState.onlyPending)
          ShadButton.ghost(
            size: ShadButtonSize.sm,
            onPressed: salesHistoryNotifier.clearFilters,
            child: const Row(
              spacing: 6,
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(LucideIcons.x, size: 14),
                Text('Limpiar filtros'),
              ],
            ),
          ),
      ],
    );
  }
}

