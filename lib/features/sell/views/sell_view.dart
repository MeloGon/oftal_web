import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
                            _PatientResultList(
                              patients: sellState.patients,
                              onSelect: (patient) {
                                sellNotifier.selectPatient(patient);
                                sellNotifier.selectItemOption(
                                  SellItemOptionsEnum.sell,
                                );
                              },
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
                        height: 340,
                        child: TooltipVisibility(
                          visible: false,
                          child: PaginatedDataTable2(
                            wrapInCard: false,
                            showCheckboxColumn: false,
                            columnSpacing: 12,
                            horizontalMargin: 16,
                            minWidth: 680,
                            isHorizontalScrollBarVisible: true,
                            isVerticalScrollBarVisible: true,
                            headingRowHeight: 38,
                            dataRowHeight: 44,
                            columnResizingParameters: ColumnResizingParameters(
                              realTime: false,
                              widgetColor: Theme.of(context).primaryColor,
                            ),
                            headingRowColor: WidgetStateProperty.all(
                              const Color(0xffFAFAFA),
                            ),
                            columns: const [
                              DataColumn2(
                                label: _SellColHeader('Marca'),
                                size: ColumnSize.M,
                              ),
                              DataColumn2(
                                label: _SellColHeader('Modelo'),
                                size: ColumnSize.M,
                              ),
                              DataColumn2(
                                label: _SellColHeader('Color'),
                                fixedWidth: 110,
                              ),
                              DataColumn2(
                                label: _SellColHeader('Descripción'),
                                size: ColumnSize.L,
                              ),
                              DataColumn2(
                                label: _SellColHeader('Óptica'),
                                size: ColumnSize.M,
                              ),
                              DataColumn2(
                                label: _SellColHeader('Precio'),
                                fixedWidth: 95,
                              ),
                              DataColumn2(
                                label: _SellColHeader(''),
                                fixedWidth: 105,
                                isResizable: false,
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
                        height: 340,
                        child: TooltipVisibility(
                          visible: false,
                          child: PaginatedDataTable2(
                            wrapInCard: false,
                            showCheckboxColumn: false,
                            columnSpacing: 12,
                            horizontalMargin: 16,
                            minWidth: 820,
                            isHorizontalScrollBarVisible: true,
                            isVerticalScrollBarVisible: true,
                            headingRowHeight: 38,
                            dataRowHeight: 44,
                            columnResizingParameters: ColumnResizingParameters(
                              realTime: false,
                              widgetColor: Theme.of(context).primaryColor,
                            ),
                            headingRowColor: WidgetStateProperty.all(
                              const Color(0xffFAFAFA),
                            ),
                            columns: const [
                              DataColumn2(
                                label: _SellColHeader('Descripción'),
                                size: ColumnSize.S,
                              ),
                              DataColumn2(
                                label: _SellColHeader('Diseño'),
                                size: ColumnSize.L,
                              ),
                              DataColumn2(
                                label: _SellColHeader('Línea'),
                                size: ColumnSize.S,
                              ),
                              DataColumn2(
                                label: _SellColHeader('Material'),
                                size: ColumnSize.S,
                              ),
                              DataColumn2(
                                label: _SellColHeader('Tecnología'),
                                size: ColumnSize.M,
                              ),
                              DataColumn2(
                                label: _SellColHeader('Cant.'),
                                fixedWidth: 58,
                              ),
                              DataColumn2(
                                label: _SellColHeader('P. Interno'),
                                fixedWidth: 95,
                              ),
                              DataColumn2(
                                label: _SellColHeader('P. Público'),
                                fixedWidth: 95,
                              ),
                              DataColumn2(
                                label: _SellColHeader(''),
                                fixedWidth: 105,
                                isResizable: false,
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
                            Focus(
                              onFocusChange: (hasFocus) {
                                if (!hasFocus) sellNotifier.applyDiscount();
                              },
                              child: ShadInputFormField(
                                readOnly: sellState.itemsToSell.isEmpty,
                                label: const Text('Descuento'),
                                controller: sellNotifier.discountController,
                                onSubmitted: (_) => sellNotifier.applyDiscount(),
                              ).constrained(width: 110),
                            ),
                            ShadInputFormField(
                              readOnly: true,
                              label: const Text('Total'),
                              controller: sellNotifier.totalController,
                            ).constrained(width: 110),
                            Focus(
                              onFocusChange: (hasFocus) {
                                if (!hasFocus) sellNotifier.leaveAccount();
                              },
                              child: ShadInputFormField(
                                readOnly: sellState.itemsToSell.isEmpty,
                                label: const Text('A cuenta'),
                                controller: sellNotifier.accountController,
                                onSubmitted: (_) => sellNotifier.leaveAccount(),
                              ).constrained(width: 110),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              spacing: 4,
                              children: [
                                RichText(
                                  text: const TextSpan(
                                    children: [
                                      TextSpan(
                                        text: 'Método de pago',
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w500,
                                          color: Color(0xff09090B),
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
                                    ],
                                  ),
                                ),
                                ShadSelect<PaymentMethodEnum>(
                                  enabled: sellState.itemsToSell.isNotEmpty,
                                  placeholder: const Text('Seleccionar'),
                                  initialValue:
                                      sellState.selectedInitialPaymentMethod,
                                  selectedOptionBuilder:
                                      (ctx, v) => Text(v.label),
                                  options:
                                      PaymentMethodEnum.values
                                          .map(
                                            (e) => ShadOption(
                                              value: e,
                                              child: Text(e.label),
                                            ),
                                          )
                                          .toList(),
                                  onChanged:
                                      sellNotifier.selectInitialPaymentMethod,
                                ).constrained(width: 150),
                              ],
                            ),
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
                            onPressed: () {
                              if (sellState.selectedInitialPaymentMethod ==
                                  null) {
                                _showSnackbar(
                                  context,
                                  SnackbarConfigModel(
                                    title: 'Campo requerido',
                                    type: SnackbarEnum.error,
                                  ),
                                  'Selecciona un método de pago antes de crear la venta',
                                );
                                return;
                              }
                              sellNotifier.createSale();
                            },
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

// ─── Column header for sell tables ──────────────────────────────────────────

class _SellColHeader extends StatelessWidget {
  const _SellColHeader(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: Color(0xff52525B),
      ),
    );
  }
}

// ─── Patient result cards ────────────────────────────────────────────────────

class _PatientResultList extends StatelessWidget {
  const _PatientResultList({
    required this.patients,
    required this.onSelect,
  });

  final List<PatientModel> patients;
  final ValueChanged<PatientModel> onSelect;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 8,
      children: [
        Text(
          '${patients.length} resultado${patients.length == 1 ? '' : 's'}',
          style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
        ),
        ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 300),
          child: ListView.separated(
            shrinkWrap: true,
            itemCount: patients.length,
            separatorBuilder: (_, __) => const SizedBox(height: 6),
            itemBuilder: (context, i) => _PatientCard(
              patient: patients[i],
              onSelect: () => onSelect(patients[i]),
            ),
          ),
        ),
      ],
    );
  }
}

class _PatientCard extends StatefulWidget {
  const _PatientCard({required this.patient, required this.onSelect});
  final PatientModel patient;
  final VoidCallback onSelect;

  @override
  State<_PatientCard> createState() => _PatientCardState();
}

class _PatientCardState extends State<_PatientCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final p = widget.patient;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onSelect,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: _hovered ? const Color(0xffF5F3FF) : Colors.white,
            border: Border.all(
              color:
                  _hovered
                      ? const Color(0xff7A6BF5)
                      : const Color(0xffE4E4E7),
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: const BoxDecoration(
                  color: Color(0xffEEECFE),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    p.name.isNotEmpty ? p.name[0].toUpperCase() : '?',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Color(0xff7A6BF5),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 3,
                  children: [
                    Text(
                      p.name,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xff18181B),
                      ),
                    ),
                    Row(
                      spacing: 12,
                      children: [
                        if (p.branch.isNotEmpty)
                          _InfoPill(
                            icon: Icons.store_outlined,
                            label: p.branch,
                          ),
                        if (p.phone.isNotEmpty)
                          _InfoPill(
                            icon: Icons.phone_outlined,
                            label: p.phone,
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                spacing: 4,
                children: [
                  Text(
                    p.registerDate,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xff71717A),
                    ),
                  ),
                  AnimatedOpacity(
                    opacity: _hovered ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 120),
                    child: const Text(
                      'Seleccionar →',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Color(0xff7A6BF5),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoPill extends StatelessWidget {
  const _InfoPill({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      spacing: 3,
      children: [
        Icon(icon, size: 11, color: const Color(0xff71717A)),
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: Color(0xff71717A)),
        ),
      ],
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
