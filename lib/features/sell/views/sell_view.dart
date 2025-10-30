import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:oftal_web/core/constants/constants.dart';
import 'package:oftal_web/core/enums/enums.dart';
import 'package:oftal_web/datatables/datatables.dart';
import 'package:oftal_web/features/sell/viewmodels/sell_provider.dart';
import 'package:oftal_web/features/sell/viewmodels/sell_state.dart';
import 'package:oftal_web/shared/extensions/extensions.dart';
import 'package:oftal_web/shared/models/shared_models.dart';
import 'package:oftal_web/shared/widgets/widgets.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class SellView extends ConsumerStatefulWidget {
  const SellView({super.key});

  @override
  ConsumerState<SellView> createState() => _SellViewState();
}

class _SellViewState extends ConsumerState<SellView> {
  final _patientsScrollController = ScrollController();
  final _mountsScrollController = ScrollController();
  final _resinsScrollController = ScrollController();

  @override
  void dispose() {
    _patientsScrollController.dispose();
    _mountsScrollController.dispose();
    _resinsScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sellNotifier = ref.watch(sellProvider.notifier);
    final sellState = ref.watch(sellProvider);

    ref.listen<SellState>(sellProvider, (previous, next) {
      if (next.errorMessage.isNotEmpty &&
          previous?.errorMessage != next.errorMessage) {
        _showSnackbar(context, next.snackbarConfig, next.errorMessage);
        Future.microtask(
          () => ref.read(sellProvider.notifier).clearErrorMessage(),
        );
      }
      if (next.isLoading && (previous?.isLoading ?? false) == false) {
        LoadingDialog().show(context);
      }
      if (!next.isLoading && (previous?.isLoading ?? false) == true) {
        if (context.mounted) {
          context.pop();
        }
      }
    });

    return SizedBox(
      child: Column(
        spacing: 20,
        children: [
          ShadCard(
            child: ShadAccordion<int>(
              children: [
                ShadAccordionItem(
                  value: 1,
                  title: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Vender',
                        style: ShadTheme.of(context).textTheme.h2,
                      ),
                      Text('Presiona para desplegar o contraer el contenido'),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 6,
                    children: [
                      Text(
                        'Para realizar una venta, debes de seguir los siguientes pasos:',
                      ),
                      Text(
                        '\u2022 Buscar un paciente por su nombre completo o un aproximado (Ingresa en el campo de busqueda el nombre del paciente)',
                      ),
                      Text(
                        '\u2022 Seleccionar el paciente a vender (Selecciona el paciente de la lista de pacientes en la columna de acciones)',
                      ),
                      Text(
                        '\u2022 Buscar los productos a vender (Ingresa en el campo de busqueda el nombre del producto)',
                      ),
                      Text(
                        '\u2022 Seleccionar los productos a vender (Selecciona el producto de la lista de productos en la columna de acciones)',
                      ),
                      Text('\u2022 Crear la nota de venta'),
                      Text(
                        '\u2022 Ingresar el importe, descuento y a cuenta en caso hubiera',
                      ),
                      Text('\u2022 Realiza la venta'),
                    ],
                  ),
                ),
              ],
            ),
          ),
          ShadCard(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ShadInput(
                  placeholder: Text('Ingrese el nombre del paciente'),
                  leading: Icon(LucideIcons.search),
                  controller: sellNotifier.searchController,
                  trailing: ShadButton(
                    height: 30,
                    onPressed: () => sellNotifier.searchPatient(),
                    child: Text(
                      AppStrings.search,
                    ),
                  ),
                  onSubmitted: (_) => sellNotifier.searchPatient(),
                ),
                if (sellState.patients.isNotEmpty && !sellState.isLoading)
                  Scrollbar(
                    controller: _patientsScrollController,
                    thumbVisibility: true,
                    child: PaginatedDataTable(
                      controller: _patientsScrollController,
                      headingRowHeight: 42,
                      dataRowMinHeight: 40,
                      columns: const [
                        DataColumn(label: Text('Nombre')),
                        DataColumn(label: Text('Fecha de registro')),
                        DataColumn(label: Text('Sucursal')),
                        DataColumn(label: Text('Teléfono')),
                        DataColumn(label: Text('Acciones')),
                      ],
                      source: PatientsDataSource(
                        patients: sellState.patients,
                        context: context,
                        isForSell: true,
                        ref: ref,
                      ),
                      availableRowsPerPage: [5, 10, 20, 50],
                      rowsPerPage: sellState.rowsPerPage,
                      onRowsPerPageChanged:
                          (value) => sellNotifier.changeRowsPerPage(value ?? 5),
                    ).box(width: MediaQuery.sizeOf(context).width * .9),
                  ),

                if (sellState.patients.isEmpty && !sellState.isLoading)
                  ShadCard(
                    height: 70,
                    child: const Center(
                      child: Text(
                        AppStrings.noPatientsFound,
                      ),
                    ),
                  ).paddingOnly(top: 20),
              ],
            ),
          ),
          if (sellState.selectedPatient != null &&
              sellState.selectedItemOption != null &&
              sellState.selectedItemOption == SellItemOptionsEnum.sell) ...[
            ShadCard(
              width: MediaQuery.sizeOf(context).width * .9,
              child: Column(
                spacing: 20,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Seleccione los productos a vender',
                    style: ShadTheme.of(context).textTheme.h2,
                  ),
                  Wrap(
                    spacing: 16,
                    runSpacing: 8,
                    direction: Axis.horizontal,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        spacing: 8,
                        children: [
                          Text('Clasificación'),
                          ShadSelect<String>(
                            placeholder: Text(AppStrings.select),
                            selectedOptionBuilder:
                                (context, value) => Text(value),
                            options:
                                OptionsToSellEnum.values
                                    .map(
                                      (e) => ShadOption(
                                        value: e.name,
                                        child: Text(e.name),
                                      ),
                                    )
                                    .toList(),
                            onChanged: (value) {
                              sellNotifier.selectOptionToSell(
                                OptionsToSellEnum.values.firstWhere(
                                  (e) => e.name == value,
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                      ConstrainedBox(
                        constraints: BoxConstraints(
                          maxWidth: MediaQuery.sizeOf(context).width * .6,
                        ),
                        child: Column(
                          children: [
                            ShadInputFormField(
                              placeholder: Text('Ingrese'),
                              label: Text('Nombre del producto'),
                              controller:
                                  sellNotifier.searchItemToSellController,
                              onSubmitted: (_) {
                                if (sellState.selectedOptionToSell ==
                                    OptionsToSellEnum.mount) {
                                  sellNotifier.getMounts();
                                }
                                if (sellState.selectedOptionToSell ==
                                    OptionsToSellEnum.resin) {
                                  sellNotifier.getResin();
                                }
                                if (sellState.selectedOptionToSell ==
                                    OptionsToSellEnum.others) {}
                              },
                            ),
                            if (sellState.mounts.isNotEmpty &&
                                !sellState.isLoading)
                              Scrollbar(
                                controller: _mountsScrollController,
                                thumbVisibility: true,
                                child: PaginatedDataTable(
                                  controller: _mountsScrollController,
                                  headingRowHeight: 42,
                                  dataRowMinHeight: 40,
                                  columns: const [
                                    DataColumn(label: Text('Marca')),
                                    DataColumn(label: Text('Modelo')),
                                    DataColumn(label: Text('Color')),
                                    DataColumn(label: Text('Descripción')),
                                    DataColumn(label: Text('Optica')),
                                    DataColumn(label: Text('Precio')),
                                    DataColumn(label: Text('Acciones')),
                                  ],
                                  source: MountsDataSource(
                                    mounts: sellState.mounts,
                                    context: context,
                                    ref: ref,
                                  ),
                                  availableRowsPerPage: [5, 10, 20, 50],
                                  rowsPerPage: sellState.rowsPerPage,
                                  onRowsPerPageChanged:
                                      (value) => sellNotifier.changeRowsPerPage(
                                        value ?? 5,
                                      ),
                                ).box(
                                  width: MediaQuery.sizeOf(context).width * .9,
                                ),
                              ),

                            if (sellState.resins.isNotEmpty &&
                                !sellState.isLoading)
                              Scrollbar(
                                controller: _resinsScrollController,
                                thumbVisibility: true,
                                child: PaginatedDataTable(
                                  controller: _resinsScrollController,
                                  headingRowHeight: 42,
                                  dataRowMinHeight: 40,
                                  columns: const [
                                    DataColumn(label: Text('Marca')),
                                    DataColumn(label: Text('Descripción')),
                                    DataColumn(label: Text('Precio')),
                                    DataColumn(label: Text('Acciones')),
                                  ],
                                  source: ResinDataSource(
                                    resins: sellState.resins,
                                    context: context,
                                    ref: ref,
                                  ),
                                  availableRowsPerPage: [5, 10, 20, 50],
                                  rowsPerPage: sellState.rowsPerPage,
                                  onRowsPerPageChanged:
                                      (value) => sellNotifier.changeRowsPerPage(
                                        value ?? 5,
                                      ),
                                ).box(
                                  width: MediaQuery.sizeOf(context).width * .9,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            ShadCard(
              width: MediaQuery.sizeOf(context).width * .9,
              child: Column(
                spacing: 20,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Nota de venta',
                    style: ShadTheme.of(context).textTheme.h2,
                  ),
                  ShadCard(
                    width: MediaQuery.sizeOf(context).width * .9,
                    child: Column(
                      spacing: 10,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: 'Paciente: ',
                              ),
                              TextSpan(
                                text: '  ',
                              ),
                              TextSpan(
                                text: sellState.selectedPatient?.name ?? '',
                                style: ShadTheme.of(context).textTheme.h4,
                              ),
                            ],
                          ),
                        ),
                        Text('Items a vender').paddingOnly(bottom: 20),
                        // Enviar el item cuando se seleccione y solo crear un modelo detalle de ventas e ir llenando con lo que se pueda, se crea un detalle de venta por cada item
                        // el venta corto es la union de los detalles de las ventas
                        if (sellState.itemsToSell.isNotEmpty)
                          ListView.separated(
                            shrinkWrap: true,
                            separatorBuilder:
                                (context, index) => const Divider(),
                            itemCount: sellState.itemsToSell.length,
                            itemBuilder: (context, index) {
                              return ShadCard(
                                child: ListTile(
                                  title: Text(
                                    sellState.itemsToSell[index].mountBrand ??
                                        sellState
                                            .itemsToSell[index]
                                            .description ??
                                        '',
                                  ),
                                  subtitle: Text(
                                    sellState.itemsToSell[index].mountModel ??
                                        sellState.itemsToSell[index].design ??
                                        '',
                                  ),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    spacing: 20,
                                    children: [
                                      Column(
                                        children: [
                                          Text(
                                            's/.${sellState.itemsToSell[index].mountPrice?.toStringAsFixed(2) ?? sellState.itemsToSell[index].price?.toStringAsFixed(2) ?? ''}',
                                            style:
                                                ShadTheme.of(
                                                  context,
                                                ).textTheme.large,
                                          ),
                                          Text(
                                            sellState
                                                    .itemsToSell[index]
                                                    .mountQuantity ??
                                                '',
                                          ),
                                        ],
                                      ),
                                      ShadTooltip(
                                        builder:
                                            (context) => const Text(
                                              'Quitar de la lista',
                                            ),
                                        child: InkWell(
                                          onTap:
                                              () =>
                                                  sellNotifier.removeItemToSell(
                                                    index,
                                                  ),
                                          child: Icon(
                                            Icons.delete_outline,
                                            size: 20,
                                            color: Colors.red,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        SizedBox(height: 20),
                        if (sellState.itemsToSell.isNotEmpty)
                          Row(
                            spacing: 10,
                            children: [
                              Text('Motivo de descuento'),
                              ShadSelect<String>(
                                placeholder: Text(AppStrings.select),
                                selectedOptionBuilder:
                                    (context, value) => Text(value),
                                options:
                                    DiscountReasonEnum.values
                                        .map(
                                          (e) => ShadOption(
                                            value: e.name,
                                            child: Text(e.name),
                                          ),
                                        )
                                        .toList(),
                                onChanged: (value) {
                                  sellNotifier.selectDiscountReason(
                                    DiscountReasonEnum.values.firstWhere(
                                      (e) => e.name == value,
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          spacing: 10,
                          children: [
                            Flexible(
                              child: ShadInputFormField(
                                readOnly: true,
                                label: Text('Importe'), //la suma de todo
                                controller: sellNotifier.importController,
                              ),
                            ),
                            Flexible(
                              child: ShadInputFormField(
                                readOnly: sellState.itemsToSell.isEmpty,
                                label: Text('Descuento'), //el descuento de todo
                                controller: sellNotifier.discountController,
                                onSubmitted:
                                    (_) => sellNotifier.applyDiscount(),
                              ),
                            ),
                            Flexible(
                              child: ShadInputFormField(
                                readOnly: true,
                                label: Text(
                                  'Total',
                                ), //la suma de todo - el descuento
                                controller: sellNotifier.totalController,
                              ),
                            ),
                            Flexible(
                              child: ShadInputFormField(
                                readOnly: sellState.itemsToSell.isEmpty,
                                label: Text('A cuenta'), //el dinero que se paga
                                controller: sellNotifier.accountController,
                                onSubmitted: (_) => sellNotifier.leaveAccount(),
                              ),
                            ),
                            Flexible(
                              child: ShadInputFormField(
                                readOnly: true,
                                label: Text('Resto'), //el dinero que se debe
                                controller: sellNotifier.restController,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          spacing: 10,
                          children: [
                            ShadButton(
                              size: ShadButtonSize.lg,
                              onPressed: () => sellNotifier.createSale(),
                              child: Text('Crear venta'),
                            ),
                            ShadButton.outline(
                              size: ShadButtonSize.lg,
                              onPressed: () => sellNotifier.cancelSale(),
                              child: Text('Cancelar'),
                            ),
                          ],
                        ).paddingOnly(top: 20),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    ).marginOnly(top: 20).paddingSymmetric(horizontal: 20);
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
