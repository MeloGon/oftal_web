import 'package:data_table_2/data_table_2.dart';
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
  final _formKey = GlobalKey<ShadFormState>();

  @override
  Widget build(BuildContext context) {
    final sellNotifier = ref.watch(sellProvider.notifier);
    final sellState = ref.watch(sellProvider);
    final size = MediaQuery.sizeOf(context);

    ref.listenLoading(sellProvider.select((s) => s.isLoading), context);

    ref.listen<SellState>(sellProvider, (previous, next) {
      if (next.errorMessage.isNotEmpty &&
          previous?.errorMessage != next.errorMessage) {
        _showSnackbar(context, next.snackbarConfig, next.errorMessage);
        Future.microtask(
          () => ref.read(sellProvider.notifier).clearErrorMessage(),
        );
      }
    });

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 20,
          children: [
            // ─── Page header ─────────────────────────────────
            const _PageHeader(),

            // ─── Step 1: Patient search ───────────────────────
            _StepCard(
              step: 1,
              title: 'Seleccionar paciente',
              subtitle:
                  sellState.selectedPatient != null
                      ? 'Paciente: ${sellState.selectedPatient!.name}'
                      : 'Busca al paciente al que deseas vender',
              isCompleted: sellState.selectedPatient != null,
              action:
                  sellState.selectedPatient != null
                      ? ShadButton.outline(
                        height: 32,
                        onPressed: sellNotifier.cancelSale,
                        child: const Row(
                          spacing: 6,
                          children: [
                            Icon(LucideIcons.x, size: 14),
                            Text('Cambiar paciente'),
                          ],
                        ),
                      )
                      : null,
              child:
                  sellState.selectedPatient != null
                      ? const SizedBox.shrink()
                      : Column(
                        spacing: 10,
                        children: [
                          ShadInput(
                            padding: const EdgeInsets.symmetric(
                              vertical: 8,
                              horizontal: 10,
                            ),
                            placeholder: const Text(
                              'Ingrese el nombre del paciente a vender',
                            ),
                            leading: const Icon(LucideIcons.search, size: 16),
                            controller: sellNotifier.searchController,
                            trailing: ShadButton(
                              height: 30,
                              onPressed: sellNotifier.searchPatient,
                              child: Text(AppStrings.search),
                            ),
                            onSubmitted: (_) => sellNotifier.searchPatient(),
                          ),
                          if (sellState.patients.isNotEmpty &&
                              !sellState.isLoading)
                            SizedBox(
                              height: 320,
                              child: TooltipVisibility(
                                visible: false,
                                child: PaginatedDataTable2(
                                  headingRowHeight: 36,
                                  wrapInCard: false,
                                  columnSpacing: 12,
                                  horizontalMargin: 12,
                                  isHorizontalScrollBarVisible: true,
                                  isVerticalScrollBarVisible: true,
                                  headingRowColor: WidgetStateProperty.all(
                                    const Color(0xffFAFAFA),
                                  ),
                                  columns: const [
                                    DataColumn2(
                                      label: Text('Nombre'),
                                      size: ColumnSize.L,
                                      minWidth: 100,
                                    ),
                                    DataColumn2(
                                      label: Text('Fecha de registro'),
                                      size: ColumnSize.M,
                                      minWidth: 100,
                                    ),
                                    DataColumn2(
                                      label: Text('Sucursal'),
                                      size: ColumnSize.M,
                                      minWidth: 90,
                                    ),
                                    DataColumn2(
                                      label: Text('Teléfono'),
                                      size: ColumnSize.M,
                                      minWidth: 100,
                                    ),
                                    DataColumn2(
                                      label: Text('Acciones'),
                                      size: ColumnSize.S,
                                    ),
                                  ],
                                  source: PatientsDataSource(
                                    patients: sellState.patients,
                                    context: context,
                                    isForSell: true,
                                    ref: ref,
                                  ),
                                  availableRowsPerPage: const [5, 10, 20, 50],
                                  rowsPerPage: sellState.rowsPerPage,
                                  onRowsPerPageChanged:
                                      (value) => sellNotifier.changeRowsPerPage(
                                        value ?? 5,
                                      ),
                                ),
                              ),
                            ),
                          if (sellState.patients.isEmpty &&
                              !sellState.isLoading)
                            Container(
                              padding: const EdgeInsets.symmetric(vertical: 20),
                              child: Center(
                                child: Text(
                                  AppStrings.noPatientsFound,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey.shade500,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
            ),

            // ─── Step 2: Product selection ────────────────────
            if (sellState.selectedPatient != null &&
                sellState.selectedItemOption == SellItemOptionsEnum.sell) ...[
              _StepCard(
                step: 2,
                title: 'Seleccionar productos',
                subtitle: 'Elige la categoría y busca el producto',
                isCompleted: sellState.itemsToSell.isNotEmpty,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 16,
                  children: [
                    Wrap(
                      spacing: 16,
                      runSpacing: 10,
                      crossAxisAlignment: WrapCrossAlignment.end,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          spacing: 6,
                          children: [
                            const Text(
                              'Clasificación',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Color(0xff52525B),
                              ),
                            ),
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
                                if (value != null) {
                                  sellNotifier.selectOptionToSell(
                                    OptionsToSellEnum.values.firstWhere(
                                      (e) => e.name == value,
                                    ),
                                  );
                                }
                              },
                            ),
                          ],
                        ),
                        ConstrainedBox(
                          constraints: BoxConstraints(
                            maxWidth: size.width * 0.5,
                          ),
                          child: ShadInputFormField(
                            placeholder: const Text(
                              'Nombre del producto a buscar',
                            ),
                            label: const Text('Producto'),
                            controller: sellNotifier.searchItemToSellController,
                            onSubmitted: (_) {
                              if (sellState.selectedOptionToSell ==
                                  OptionsToSellEnum.mount) {
                                sellNotifier.getMounts();
                              } else if (sellState.selectedOptionToSell ==
                                  OptionsToSellEnum.resin) {
                                sellNotifier.getResin();
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                    if (sellState.mounts.isNotEmpty && !sellState.isLoading)
                      SizedBox(
                        width: double.infinity,
                        height: 320,
                        child: TooltipVisibility(
                          visible: false,
                          child: PaginatedDataTable2(
                            wrapInCard: false,
                            columnSpacing: 12,
                            horizontalMargin: 12,
                            minWidth: 800,
                            isHorizontalScrollBarVisible: true,
                            isVerticalScrollBarVisible: true,
                            headingRowHeight: 38,
                            headingRowColor: WidgetStateProperty.all(
                              const Color(0xffFAFAFA),
                            ),
                            columns: const [
                              DataColumn2(
                                label: Text('Marca'),
                                fixedWidth: 120,
                                isResizable: true,
                              ),
                              DataColumn2(
                                label: Text('Modelo'),
                                fixedWidth: 100,
                                isResizable: true,
                              ),
                              DataColumn2(
                                label: Text('Color'),
                                fixedWidth: 120,
                                isResizable: true,
                              ),
                              DataColumn2(
                                label: Text('Descripción'),
                                fixedWidth: 150,
                                isResizable: true,
                              ),
                              DataColumn2(
                                label: Text('Optica'),
                                fixedWidth: 100,
                                isResizable: true,
                              ),
                              DataColumn2(
                                label: Text('Precio'),
                                fixedWidth: 90,
                                isResizable: true,
                              ),
                              DataColumn2(
                                label: Text('Acciones'),
                                fixedWidth: 90,
                                isResizable: true,
                              ),
                            ],
                            source: MountsDataSource(
                              mounts: sellState.mounts,
                              context: context,
                              ref: ref,
                            ),
                            availableRowsPerPage: const [5, 10, 20, 50],
                            rowsPerPage: sellState.rowsPerPage,
                            onRowsPerPageChanged:
                                (value) =>
                                    sellNotifier.changeRowsPerPage(value ?? 5),
                          ),
                        ),
                      ),
                    if (sellState.resins.isNotEmpty && !sellState.isLoading)
                      SizedBox(
                        width: double.infinity,
                        height: 320,
                        child: TooltipVisibility(
                          visible: false,
                          child: PaginatedDataTable2(
                            wrapInCard: false,
                            columnSpacing: 12,
                            horizontalMargin: 12,
                            minWidth: 900,
                            isHorizontalScrollBarVisible: true,
                            isVerticalScrollBarVisible: true,
                            headingRowHeight: 38,
                            headingRowColor: WidgetStateProperty.all(
                              const Color(0xffFAFAFA),
                            ),
                            columns: const [
                              DataColumn2(
                                label: Text('Descripción'),
                                fixedWidth: 120,
                                isResizable: true,
                              ),
                              DataColumn2(
                                label: Text('Diseño'),
                                fixedWidth: 180,
                                isResizable: true,
                              ),
                              DataColumn2(
                                label: Text('Linea'),
                                fixedWidth: 100,
                                isResizable: true,
                              ),
                              DataColumn2(
                                label: Text('Material'),
                                fixedWidth: 100,
                                isResizable: true,
                              ),
                              DataColumn2(
                                label: Text('Tecnología'),
                                fixedWidth: 130,
                                isResizable: true,
                              ),
                              DataColumn2(
                                label: Text('Cant.'),
                                fixedWidth: 60,
                                isResizable: true,
                              ),
                              DataColumn2(
                                label: Text('P. Interno'),
                                fixedWidth: 90,
                                isResizable: true,
                              ),
                              DataColumn2(
                                label: Text('P. Público'),
                                fixedWidth: 90,
                                isResizable: true,
                              ),
                              DataColumn2(
                                label: Text('Acciones'),
                                fixedWidth: 80,
                                isResizable: true,
                              ),
                            ],
                            source: ResinDataSource(
                              resins: sellState.resins,
                              context: context,
                              ref: ref,
                            ),
                            availableRowsPerPage: const [5, 10, 20, 50],
                            rowsPerPage: sellState.rowsPerPage,
                            onRowsPerPageChanged:
                                (value) =>
                                    sellNotifier.changeRowsPerPage(value ?? 5),
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              // ─── Step 3: Invoice ──────────────────────────
              _StepCard(
                step: 3,
                title: 'Nota de venta',
                subtitle: 'Revisa los productos y confirma la venta',
                isCompleted: false,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 16,
                  children: [
                    // Patient + date row
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            spacing: 4,
                            children: [
                              const Text(
                                'Paciente',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Color(0xff71717A),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Text(
                                sellState.selectedPatient?.name ?? '',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xff18181B),
                                ),
                              ),
                            ],
                          ),
                        ),
                        ShadForm(
                          key: _formKey,
                          autovalidateMode:
                              ShadAutovalidateMode.onUserInteraction,
                          child: ShadInputFormField(
                            label: const Text('Fecha'),
                            inputFormatters: [sellNotifier.mask],
                            controller: sellNotifier.dateController,
                            validator:
                                (v) =>
                                    RegExp(
                                          r'^(0[1-9]|[12][0-9]|3[01])-(0[1-9]|1[0-2])-(19|20)\d{2}$',
                                        ).hasMatch(v)
                                        ? null
                                        : 'Ingresa una fecha válida',
                          ).constrained(width: 130),
                        ),
                      ],
                    ),

                    // Seller row
                    Row(
                      spacing: 10,
                      children: [
                        RichText(
                          text: const TextSpan(
                            children: [
                              TextSpan(
                                text: 'Vendedor',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xff3F3F46),
                                ),
                              ),
                              TextSpan(
                                text: ' *',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xffEF4444),
                                ),
                              ),
                              TextSpan(
                                text: ':',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xff3F3F46),
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (sellState.sellers.isNotEmpty)
                          ShadSelect<SellerModel>(
                            placeholder: Text(AppStrings.select),
                            initialValue: sellState.selectedSeller,
                            selectedOptionBuilder:
                                (context, value) => Text(value.name),
                            options:
                                sellState.sellers
                                    .map(
                                      (e) => ShadOption(
                                        value: e,
                                        child: Text(e.name),
                                      ),
                                    )
                                    .toList(),
                            onChanged: sellNotifier.updateSelectedSeller,
                          ).constrained(width: 200),
                      ],
                    ),

                    const Divider(height: 1),

                    // Items list
                    const Text(
                      'Productos en la nota',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xff3F3F46),
                      ),
                    ),
                    if (sellState.itemsToSell.isNotEmpty)
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemCount: sellState.itemsToSell.length,
                        itemBuilder: (context, index) {
                          final item = sellState.itemsToSell[index];
                          return _SellItemCard(
                            key: ValueKey(item.id),
                            item: item,
                            onRemove:
                                () => sellNotifier.removeItemToSell(index),
                            onPriceChanged:
                                (price) =>
                                    sellNotifier.updateItemPrice(index, price),
                          );
                        },
                      )
                    else
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 24),
                        child: Center(
                          child: Text(
                            'Aún no has agregado productos',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ),
                      ),

                    if (sellState.itemsToSell.isNotEmpty) ...[
                      const Divider(height: 1),

                      // Discount reason
                      Row(
                        spacing: 10,
                        children: [
                          const Text(
                            'Motivo de descuento:',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: Color(0xff3F3F46),
                            ),
                          ),
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
                              if (value != null) {
                                sellNotifier.selectDiscountReason(
                                  DiscountReasonEnum.values.firstWhere(
                                    (e) => e.name == value,
                                  ),
                                );
                              }
                            },
                          ),
                        ],
                      ),

                      // Totals grid
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xffFAFAFA),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xffE4E4E7)),
                        ),
                        child: Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children: [
                            ShadInputFormField(
                              readOnly: true,
                              label: const Text('Importe'),
                              controller: sellNotifier.importController,
                            ).constrained(width: 110),
                            ShadInputFormField(
                              readOnly: sellState.itemsToSell.isEmpty,
                              label: const Text('Descuento'),
                              controller: sellNotifier.discountController,
                              onSubmitted: (_) => sellNotifier.applyDiscount(),
                            ).constrained(width: 110),
                            ShadInputFormField(
                              readOnly: true,
                              label: const Text('Total'),
                              controller: sellNotifier.totalController,
                            ).constrained(width: 110),
                            ShadInputFormField(
                              readOnly: sellState.itemsToSell.isEmpty,
                              label: const Text('A cuenta'),
                              controller: sellNotifier.accountController,
                              onSubmitted: (_) => sellNotifier.leaveAccount(),
                            ).constrained(width: 110),
                            ShadInputFormField(
                              readOnly: true,
                              label: const Text('Resto'),
                              controller: sellNotifier.restController,
                            ).constrained(width: 110),
                          ],
                        ),
                      ),

                      // Action buttons
                      Row(
                        spacing: 12,
                        children: [
                          ShadButton(
                            size: ShadButtonSize.lg,
                            onPressed: sellNotifier.createSale,
                            child: const Row(
                              spacing: 8,
                              children: [
                                Icon(Icons.check_circle_outline, size: 16),
                                Text('Crear venta'),
                              ],
                            ),
                          ),
                          ShadButton.outline(
                            size: ShadButtonSize.lg,
                            onPressed: sellNotifier.cancelSale,
                            child: const Text('Cancelar'),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ─── Local widgets ──────────────────────────────────────────────────────────

class _PageHeader extends StatelessWidget {
  const _PageHeader();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 4,
      children: [
        const Text(
          'Nueva Venta',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: Color(0xff18181B),
          ),
        ),
        Text(
          'Sigue los pasos para registrar una venta',
          style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
        ),
      ],
    );
  }
}

class _StepCard extends StatelessWidget {
  const _StepCard({
    required this.step,
    required this.title,
    required this.subtitle,
    required this.isCompleted,
    required this.child,
    this.action,
  });

  final int step;
  final String title;
  final String subtitle;
  final bool isCompleted;
  final Widget child;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return ShadCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 16,
        children: [
          // Step header
          Row(
            spacing: 12,
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color:
                      isCompleted
                          ? const Color(0xff10B981)
                          : const Color(0xff7A6BF5),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child:
                      isCompleted
                          ? const Icon(
                            Icons.check,
                            size: 14,
                            color: Colors.white,
                          )
                          : Text(
                            '$step',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 2,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xff18181B),
                      ),
                    ),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xff71717A),
                      ),
                    ),
                  ],
                ),
              ),
              if (action != null) action!,
            ],
          ),
          const Divider(height: 1),
          child,
        ],
      ),
    );
  }
}

class _SellItemCard extends StatefulWidget {
  const _SellItemCard({
    super.key,
    required this.item,
    required this.onRemove,
    required this.onPriceChanged,
  });
  final SalesDetailsModel item;
  final VoidCallback onRemove;
  final ValueChanged<double> onPriceChanged;

  @override
  State<_SellItemCard> createState() => _SellItemCardState();
}

class _SellItemCardState extends State<_SellItemCard> {
  late final TextEditingController _priceCtrl;

  @override
  void initState() {
    super.initState();
    final price = widget.item.mountPrice ?? widget.item.price ?? 0.0;
    _priceCtrl = TextEditingController(text: price.toStringAsFixed(2));
  }

  @override
  void dispose() {
    _priceCtrl.dispose();
    super.dispose();
  }

  void _commit() {
    final parsed = double.tryParse(_priceCtrl.text);
    if (parsed != null) widget.onPriceChanged(parsed);
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xffFAFAFA),
        border: Border.all(color: const Color(0xffE4E4E7)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 2,
              children: [
                Text(
                  item.mountBrand ?? item.description ?? '',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xff18181B),
                  ),
                ),
                Text(
                  item.mountModel ?? item.design ?? '',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xff71717A),
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            spacing: 4,
            children: [
              ShadInput(
                controller: _priceCtrl,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                onSubmitted: (_) => _commit(),
                onEditingComplete: _commit,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                // prefix: const Text(
                //   's/. ',
                //   style: TextStyle(fontSize: 12, color: Color(0xff71717A)),
                // ),
              ).constrained(width: 110),
              Text(
                'Cant. ${item.mountQuantity ?? item.quantity ?? ''}',
                style: const TextStyle(fontSize: 11, color: Color(0xff71717A)),
              ),
            ],
          ),
          const SizedBox(width: 12),
          Material(
            type: MaterialType.transparency,
            child: InkWell(
              onTap: widget.onRemove,
              borderRadius: BorderRadius.circular(6),
              child: Padding(
                padding: const EdgeInsets.all(4),
                child: Icon(
                  Icons.delete_outline,
                  size: 18,
                  color: Colors.red.shade400,
                ),
              ),
            ),
          ),
        ],
      ),
    );
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
