import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:oftal_web/features/sales_history/viewmodels/sales_history_provider.dart';
import 'package:oftal_web/shared/extensions/extensions.dart';
import 'package:oftal_web/shared/models/shared_models.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class SalesDetailsDialog {
  Future<void> show(
    BuildContext context,
    List<SalesDetailsModel> saleDetails,
    SalesModel sale,
    WidgetRef ref,
  ) async {
    return showShadDialog(
      context: context,

      builder:
          (context) => ShadDialog(
            closeIcon: ShadIconButton(
              icon: Icon(Icons.close),
              onPressed: () {
                ref
                    .read(salesHistoryProvider.notifier)
                    .clearSaleSelectedForDetails();
                context.pop();
              },
            ),
            title: Text('Detalles de la venta'),
            description: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Ventas encontradas'),
                    Text('${saleDetails.length}'),
                  ],
                ),
                Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Total sin descuento'),
                    Text('${sale.total?.toCurrency()}'),
                  ],
                ),
                Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Descuento'),
                    Text('${sale.discount?.toCurrency()}'),
                  ],
                ),
                Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Total con descuento'),
                    Text('${sale.totalWithDiscount?.toCurrency()}'),
                  ],
                ),
                Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('A cuenta'),
                    Text('${sale.account?.toCurrency()}'),
                  ],
                ),
                Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Resto'),
                    Text('${sale.rest?.toCurrency()}'),
                  ],
                ),
              ],
            ),
            child: SalesDetailsWidget(
              saleDetails: saleDetails,
              sale: sale,
            ),
          ),
    );
  }
}

class SalesDetailsWidget extends StatelessWidget {
  final List<SalesDetailsModel> saleDetails;
  final SalesModel sale;
  const SalesDetailsWidget({
    super.key,
    required this.saleDetails,
    required this.sale,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: 15,
      children:
          saleDetails
              .map(
                (saleDetail) => ShadCard(
                  title: Text(
                    'Venta del ${saleDetail.dateSale ?? ''} Precio sin dscto. s/. ${(saleDetail.price ?? 0) + (saleDetail.mountPrice ?? 0)}',
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Detalles de la venta',
                        style: ShadTheme.of(context).textTheme.h2,
                      ),
                      if (saleDetail.patient != null &&
                          saleDetail.patient != '')
                        RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(text: 'Paciente: '),
                              TextSpan(
                                text: saleDetail.patient,
                              ),
                            ],
                          ),
                        ),
                      if (saleDetail.design != null && saleDetail.design != '')
                        RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(text: 'Diseño: '),
                              TextSpan(
                                text: saleDetail.design,
                              ),
                            ],
                          ),
                        ),
                      if (saleDetail.line != null && saleDetail.line != '')
                        RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(text: 'Linea: '),
                              TextSpan(
                                text: saleDetail.line,
                              ),
                            ],
                          ),
                        ),
                      if (saleDetail.material != null &&
                          saleDetail.material != '')
                        RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(text: 'Material: '),
                              TextSpan(
                                text: saleDetail.material,
                              ),
                            ],
                          ),
                        ),
                      if (saleDetail.technology != null &&
                          saleDetail.technology != '')
                        RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(text: 'Tecnología: '),
                              TextSpan(
                                text: saleDetail.technology,
                              ),
                            ],
                          ),
                        ),
                      if (saleDetail.serie != null && saleDetail.serie != '')
                        RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(text: 'Serie: '),
                              TextSpan(
                                text: saleDetail.serie,
                              ),
                            ],
                          ),
                        ),
                      if (saleDetail.text != null && saleDetail.text != '')
                        RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(text: 'Texto: '),
                              TextSpan(
                                text: saleDetail.text,
                              ),
                            ],
                          ),
                        ),
                      if (saleDetail.quantity != null &&
                          saleDetail.quantity != '')
                        RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(text: 'Cantidad: '),
                              TextSpan(
                                text: saleDetail.quantity,
                              ),
                            ],
                          ),
                        ),
                      if (saleDetail.price != null)
                        RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(text: 'Precio: '),
                              TextSpan(
                                text: saleDetail.price.toString(),
                              ),
                            ],
                          ),
                        ),
                      if (saleDetail.mount != null && saleDetail.mount != '')
                        RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(text: 'Montura: '),
                              TextSpan(
                                text: saleDetail.mount,
                              ),
                            ],
                          ),
                        ),
                      if (saleDetail.mountBrand != null &&
                          saleDetail.mountBrand != '')
                        RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(text: 'Montura marca: '),
                              TextSpan(
                                text: saleDetail.mountBrand,
                              ),
                            ],
                          ),
                        ),
                      if (saleDetail.mountModel != null &&
                          saleDetail.mountModel != '')
                        RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(text: 'Montura modelo: '),
                              TextSpan(
                                text: saleDetail.mountModel,
                              ),
                            ],
                          ),
                        ),
                      if (saleDetail.mountQuantity != null &&
                          saleDetail.mountQuantity != '')
                        RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(text: 'Montura cantidad: '),
                              TextSpan(
                                text: saleDetail.mountQuantity,
                              ),
                            ],
                          ),
                        ),
                      if (saleDetail.mountPrice != null &&
                          saleDetail.mountPrice != 0)
                        RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(text: 'Montura precio: '),
                              TextSpan(
                                text: saleDetail.mountPrice.toString(),
                              ),
                            ],
                          ),
                        ),
                      if (saleDetail.mountText != null &&
                          saleDetail.mountText != '')
                        RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(text: 'Montura texto: '),
                              TextSpan(
                                text: saleDetail.mountText,
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              )
              .toList(),
    );
  }
}
