import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
    return SizedBox(
      child: Column(
        spacing: 20,
        children: [
          ShadCard(
            width: MediaQuery.sizeOf(context).width * .9,
            child: ShadCard(
              height: 400,
              child: Scrollbar(
                thumbVisibility: true,
                child: CustomScrollView(
                  primary: true,
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
                    (salesState.sales.isNotEmpty)
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
                                    'S/. ${sale.total.toStringAsFixed(2)}',
                                    style:
                                        ShadTheme.of(context).textTheme.large,
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
              ref.watch(salesHistoryProvider).saleSelectedForDetails?.id != 0)
            ShadCard(
              width: MediaQuery.sizeOf(context).width * .9,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Align(
                    alignment: Alignment.topRight,
                    child: IconButton(
                      onPressed: salesNotifier.closeSaleDetails,

                      icon: Icon(
                        Icons.close,
                        size: 20,
                      ),
                    ),
                  ),
                  Text(
                    'Detalles de la venta',
                    style: ShadTheme.of(context).textTheme.h2,
                  ),
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(text: 'Fecha de la venta: '),
                        TextSpan(text: salesState.saleDetails?.dateSale),
                      ],
                    ),
                  ),
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(text: 'Paciente: '),
                        TextSpan(text: salesState.saleDetails?.patient),
                      ],
                    ),
                  ),
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(text: 'Descripción: '),
                        TextSpan(text: salesState.saleDetails?.description),
                      ],
                    ),
                  ),
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(text: 'Diseño: '),
                        TextSpan(text: salesState.saleDetails?.design),
                      ],
                    ),
                  ),
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(text: 'Linea: '),
                        TextSpan(text: salesState.saleDetails?.line),
                      ],
                    ),
                  ),
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(text: 'Material: '),
                        TextSpan(text: salesState.saleDetails?.material),
                      ],
                    ),
                  ),
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(text: 'Tecnología: '),
                        TextSpan(text: salesState.saleDetails?.technology),
                      ],
                    ),
                  ),
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(text: 'Serie: '),
                        TextSpan(text: salesState.saleDetails?.serie),
                      ],
                    ),
                  ),
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(text: 'Texto: '),
                        TextSpan(text: salesState.saleDetails?.text),
                      ],
                    ),
                  ),
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(text: 'Cantidad: '),
                        TextSpan(text: salesState.saleDetails?.quantity),
                      ],
                    ),
                  ),
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(text: 'Precio: '),
                        TextSpan(
                          text: salesState.saleDetails?.price.toString(),
                        ),
                      ],
                    ),
                  ),
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(text: 'Montura: '),
                        TextSpan(text: salesState.saleDetails?.mount),
                      ],
                    ),
                  ),
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(text: 'Montura marca: '),
                        TextSpan(text: salesState.saleDetails?.mountBrand),
                      ],
                    ),
                  ),
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(text: 'Montura modelo: '),
                        TextSpan(text: salesState.saleDetails?.mountModel),
                      ],
                    ),
                  ),
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(text: 'Montura cantidad: '),
                        TextSpan(text: salesState.saleDetails?.mountQuantity),
                      ],
                    ),
                  ),
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(text: 'Montura precio: '),
                        TextSpan(
                          text: salesState.saleDetails?.mountPrice.toString(),
                        ),
                      ],
                    ),
                  ),
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(text: 'Montura texto: '),
                        TextSpan(text: salesState.saleDetails?.mountText),
                      ],
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    ).marginOnly(top: 50).paddingSymmetric(horizontal: 20);
  }
}
