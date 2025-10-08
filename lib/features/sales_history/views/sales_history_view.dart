import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:oftal_web/features/sales_history/views/widgets/sales_details_section.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:oftal_web/features/sales_history/viewmodels/sales_history_provider.dart';
import 'package:oftal_web/features/sales_history/views/widgets/label_sales_item.dart';
import 'package:oftal_web/shared/extensions/extensions.dart';

class SalesHistoryView extends ConsumerWidget {
  const SalesHistoryView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final salesState = ref.watch(salesHistoryProvider);
    final salesNotifier = ref.watch(salesHistoryProvider.notifier);
    return Column(
      spacing: 20,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ShadCard(
          width: MediaQuery.sizeOf(context).width * .9,
          child: ShadCard(
            height: 700,
            child: Scrollbar(
              thumbVisibility: true,
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: Text(
                      'Ventas realizadas',
                      style: ShadTheme.of(context).textTheme.h2,
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: ShadInputFormField(
                      controller: salesNotifier.searchController,
                      placeholder: Text('Ingresa el nombre del paciente'),
                      onSubmitted: (_) => salesNotifier.getSales(),
                      trailing: ShadButton(
                        onPressed: () {
                          salesNotifier.searchController.clear();
                          salesNotifier.getSales();
                        },
                        child: Icon(Icons.close),
                      ),
                    ).paddingOnly(
                      top: 10,
                      bottom: 20,
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Text(
                      'Se encontraron (${salesState.sales.length}) resultados, escrollea para ver las ventas',
                    ),
                  ),
                  if (salesState.isLoading)
                    SliverToBoxAdapter(
                      child: Center(
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      ),
                    ),
                  (salesState.sales.isNotEmpty && !salesState.isLoading)
                      ? SliverList.separated(
                        separatorBuilder: (context, index) => const Divider(),
                        itemBuilder: (context, index) {
                          final sale = salesState.sales[index];
                          return ListTile(
                            title: LabelSalesItem(
                              title: 'Paciente',
                              content: sale.patient.toString(),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                LabelSalesItem(
                                  title: 'Fecha',
                                  content: sale.date.toString(),
                                ),
                                LabelSalesItem(
                                  title: 'Vendedor',
                                  content: sale.authorName.toString(),
                                ),
                              ],
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              spacing: 10,
                              children: [
                                Text(
                                  'S/. ${sale.total?.toStringAsFixed(2)}',
                                  style: ShadTheme.of(context).textTheme.large,
                                ),
                                ShadIconButton(
                                  icon: Icon(LucideIcons.eye300),
                                  onPressed: () {
                                    salesNotifier.selectSaleForDetails(sale);
                                  },
                                ),
                              ],
                            ),
                          );
                        },
                        itemCount: salesState.sales.length,
                      )
                      : SliverToBoxAdapter(
                        child: Text(
                          'No se encontraron ventas',
                        ),
                      ),
                ],
              ),
            ),
          ).paddingOnly(top: 20),
        ),
        if (ref.watch(salesHistoryProvider).saleSelectedForDetails?.id !=
                null &&
            ref.watch(salesHistoryProvider).saleSelectedForDetails?.id != 0 &&
            !ref.watch(salesHistoryProvider).isLoading)
          Wrap(
            spacing: 20,
            runSpacing: 20,
            children: [
              SalesDetailsSection(),
            ],
          ),
      ],
    ).paddingSymmetric(horizontal: 20, vertical: 50);
  }
}
