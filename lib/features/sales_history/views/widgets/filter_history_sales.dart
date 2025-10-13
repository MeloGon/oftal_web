import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:oftal_web/core/constants/constants.dart';
import 'package:oftal_web/core/enums/enums.dart';
import 'package:oftal_web/features/sales_history/viewmodels/sales_history_provider.dart';
import 'package:oftal_web/shared/extensions/extensions.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class FilterHistorySales extends ConsumerWidget {
  const FilterHistorySales({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final salesHistoryState = ref.watch(salesHistoryProvider);
    final salesHistoryNotifier = ref.read(salesHistoryProvider.notifier);
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      direction: Axis.horizontal,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Text('Filtrar por :'),
        ShadSelect<FilterToSalesHistory>(
          placeholder: Text(AppStrings.select),
          selectedOptionBuilder: (context, value) => Text(value.label),
          options:
              FilterToSalesHistory.values
                  .map(
                    (e) => ShadOption(value: e, child: Text(e.label)),
                  )
                  .toList(),
          onChanged:
              (value) => salesHistoryNotifier.selectFilter(
                value ?? FilterToSalesHistory.date,
              ),
        ),
        if (salesHistoryState.selectedFilter == FilterToSalesHistory.patient)
          ShadInputFormField(
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
          ).paddingOnly(
            top: 10,
            bottom: 20,
          ),
        if (salesHistoryState.selectedFilter == FilterToSalesHistory.folio)
          ShadInputFormField(
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
          ),
        if (salesHistoryState.selectedFilter == FilterToSalesHistory.date)
          ShadInputFormField(
            inputFormatters: [
              salesHistoryNotifier.mask,
            ],
            placeholder: Text(
              'Ingresa la fecha en formato 31-04-2000 (día - mes - año)',
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
          ),
      ],
    );
  }
}
