import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:oftal_web/features/sales_history/viewmodels/sales_history_provider.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class SalesDetailsSection extends ConsumerWidget {
  const SalesDetailsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final salesState = ref.watch(salesHistoryProvider);
    return ShadCard(
      width: MediaQuery.sizeOf(context).width * .9,
      padding: EdgeInsets.symmetric(horizontal: 40, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Suma de todas los montos: s/.${salesState.saleSelectedForDetails?.total?.toStringAsFixed(2)} ',
                style: ShadTheme.of(context).textTheme.h4,
              ),
              ShadIconButton(
                icon: Icon(Icons.close),
                onPressed: () {
                  ref.read(salesHistoryProvider.notifier).closeSaleDetails();
                },
              ),
            ],
          ),
          ShadAccordion<String>.multiple(
            children:
                salesState.saleDetails
                    .map(
                      (saleDetail) => ShadAccordionItem(
                        value: saleDetail.id.toString(),
                        title: Text(
                          'Venta del ${saleDetail.dateSale ?? ''} por el monto de s/. ${(saleDetail.price ?? 0) + (saleDetail.mountPrice ?? 0)}',
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Detalles de la venta',
                              style: ShadTheme.of(context).textTheme.h2,
                            ),
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
          ),
        ],
      ),
    );
  }
}
