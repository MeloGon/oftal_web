import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:oftal_web/core/constants/constants.dart';
import 'package:oftal_web/core/enums/enums.dart';
import 'package:oftal_web/core/theme/app_text_styles.dart';
import 'package:oftal_web/features/sales_history/viewmodels/sales_history_provider.dart';
import 'package:oftal_web/shared/extensions/extensions.dart';
import 'package:oftal_web/shared/widgets/widgets.dart';
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
            ShadSelect<FilterToSalesHistory>(
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
          StatefulBuilder(
            builder:
                (context, setLocalState) => AppDatePickerButton(
                  selectedDate: salesHistoryNotifier.searchDate,
                  lastDate: DateTime.now(),
                  onDateSelected: (date) {
                    setLocalState(() {});
                    salesHistoryNotifier.updateSearchDate(date);
                  },
                ),
          ),
      ],
    );
  }
}
