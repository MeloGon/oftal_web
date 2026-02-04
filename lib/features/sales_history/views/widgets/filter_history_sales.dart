import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:oftal_web/core/constants/constants.dart';
import 'package:oftal_web/core/enums/enums.dart';
import 'package:oftal_web/core/theme/app_text_styles.dart';
import 'package:oftal_web/features/sales_history/viewmodels/sales_history_provider.dart';
import 'package:oftal_web/shared/extensions/extensions.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class FilterHistorySales extends ConsumerWidget {
  const FilterHistorySales({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final size = MediaQuery.of(context).size;
    final salesHistoryState = ref.watch(salesHistoryProvider);
    final salesHistoryNotifier = ref.read(salesHistoryProvider.notifier);
    return Wrap(
      spacing: 20,
      runSpacing: 10,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Filtrar por :', style: AppTextStyles(context).small13),
            const SizedBox(width: 10),
            DropdownButtonFormField<FilterToSalesHistory>(
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
              ),
              hint: Text(AppStrings.select),
              initialValue: salesHistoryState.selectedFilter,
              items:
                  FilterToSalesHistory.values
                      .map(
                        (e) => DropdownMenuItem(
                          value: e,
                          child: Text(e.label),
                        ),
                      )
                      .toList(),
              onChanged: (value) {
                if (value != null) {
                  salesHistoryNotifier.selectFilter(value);
                }
              },
              isExpanded: true,
            ).constrained(width: 200, height: 30),
          ],
        ),
        if (salesHistoryState.selectedFilter == FilterToSalesHistory.patient)
          ShadInputFormField(
            padding: EdgeInsets.symmetric(vertical: 6, horizontal: 6),
            controller: salesHistoryNotifier.searchController,
            placeholder: Text('Ingresa el nombre del paciente'),
            onSubmitted: (_) => salesHistoryNotifier.getSales(),
            trailing:
                salesHistoryNotifier.searchController.text.isEmpty
                    ? null
                    : ShadButton(
                      onPressed: () {
                        salesHistoryNotifier.searchController.clear();
                        salesHistoryNotifier.getSales();
                      },
                      child: Icon(Icons.close),
                    ),
          ).constrained(width: size.width * .48),
        if (salesHistoryState.selectedFilter == FilterToSalesHistory.folio)
          ShadInputFormField(
            padding: EdgeInsets.symmetric(vertical: 6, horizontal: 6),
            controller: salesHistoryNotifier.searchController,
            placeholder: Text('Ingresa el numero de folio'),
            onSubmitted: (_) => salesHistoryNotifier.getSales(),
            trailing:
                salesHistoryNotifier.searchController.text.isEmpty
                    ? null
                    : ShadButton(
                      onPressed: () {
                        salesHistoryNotifier.searchController.clear();
                        salesHistoryNotifier.getSales();
                      },
                      child: Icon(Icons.close),
                    ),
          ).constrained(width: size.width * .4),
        if (salesHistoryState.selectedFilter == FilterToSalesHistory.date)
          ShadInputFormField(
            padding: EdgeInsets.symmetric(vertical: 6, horizontal: 6),
            inputFormatters: [
              salesHistoryNotifier.mask,
            ],
            placeholder: Text(
              'Ingresa la fecha ejm. 2026-04-31 (año - mes - día)',
            ),
            onSubmitted: (_) => salesHistoryNotifier.getSales(),
            controller: salesHistoryNotifier.searchController,
            validator:
                (v) =>
                    RegExp(
                          r'^(19|20)\d{2}-(0[1-9]|1[0-2])-(0[1-9]|[12][0-9]|3[01])$',
                        ).hasMatch(v)
                        ? null
                        : 'Ingresa una fecha valida',
          ).constrained(width: size.width * .4),
      ],
    );
  }
}
