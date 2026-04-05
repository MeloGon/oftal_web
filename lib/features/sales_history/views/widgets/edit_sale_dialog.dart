import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:oftal_web/features/sales_history/viewmodels/sales_history_provider.dart';
import 'package:oftal_web/shared/extensions/extensions.dart';
import 'package:oftal_web/shared/models/shared_models.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class EditSaleDialog {
  Future<void> show(
    BuildContext context,
    WidgetRef ref,
    SalesModel sale,
    List<SalesDetailsModel> details,
  ) async {
    return showShadDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) =>
          _EditSaleContent(sale: sale, details: details, ref: ref),
    );
  }
}

// ─── Main stateful dialog content ─────────────────────────────────────────────

class _EditSaleContent extends StatefulWidget {
  const _EditSaleContent({
    required this.sale,
    required this.details,
    required this.ref,
  });
  final SalesModel sale;
  final List<SalesDetailsModel> details;
  final WidgetRef ref;

  @override
  State<_EditSaleContent> createState() => _EditSaleContentState();
}

class _EditSaleContentState extends State<_EditSaleContent> {
  late final TextEditingController _discountCtrl;
  late final TextEditingController _accountCtrl;
  late final List<TextEditingController> _lensPriceCtrl;
  late final List<TextEditingController> _mountPriceCtrl;

  @override
  void initState() {
    super.initState();
    _discountCtrl = TextEditingController(
      text: (widget.sale.discount ?? 0).toStringAsFixed(2),
    );
    _accountCtrl = TextEditingController(
      text: (widget.sale.account ?? 0).toStringAsFixed(2),
    );
    _lensPriceCtrl = widget.details
        .map(
          (d) => TextEditingController(
            text: (d.price ?? 0).toStringAsFixed(2),
          ),
        )
        .toList();
    _mountPriceCtrl = widget.details
        .map(
          (d) => TextEditingController(
            text: (d.mountPrice ?? 0).toStringAsFixed(2),
          ),
        )
        .toList();

    void rebuild() => setState(() {});
    _discountCtrl.addListener(rebuild);
    _accountCtrl.addListener(rebuild);
    for (final c in _lensPriceCtrl) {
      c.addListener(rebuild);
    }
    for (final c in _mountPriceCtrl) {
      c.addListener(rebuild);
    }
  }

  @override
  void dispose() {
    _discountCtrl.dispose();
    _accountCtrl.dispose();
    for (final c in _lensPriceCtrl) {
      c.dispose();
    }
    for (final c in _mountPriceCtrl) {
      c.dispose();
    }
    super.dispose();
  }

  // ─── Computed properties ─────────────────────────────────────────────────

  double get _computedTotal {
    double sum = 0;
    for (int i = 0; i < _lensPriceCtrl.length; i++) {
      sum += double.tryParse(_lensPriceCtrl[i].text) ?? 0;
      sum += double.tryParse(_mountPriceCtrl[i].text) ?? 0;
    }
    return sum;
  }

  double get _computedDiscount => double.tryParse(_discountCtrl.text) ?? 0;
  double get _computedTotalWithDiscount => _computedTotal - _computedDiscount;
  double get _computedAccount => double.tryParse(_accountCtrl.text) ?? 0;
  double get _computedRest => _computedTotalWithDiscount - _computedAccount;

  // ─── Actions ─────────────────────────────────────────────────────────────

  void _finalize() {
    _accountCtrl.text = _computedTotalWithDiscount.toStringAsFixed(2);
    _save();
  }

  void _save() {
    final updatedSale = SalesModel(
      id: widget.sale.id,
      branch: widget.sale.branch,
      date: widget.sale.date,
      patient: widget.sale.patient,
      authorName: widget.sale.authorName,
      total: _computedTotal,
      discount: _computedDiscount,
      totalWithDiscount: _computedTotalWithDiscount,
      account: _computedAccount,
      rest: _computedRest,
      folioSale: widget.sale.folioSale,
      updatedDate: widget.sale.updatedDate,
    );
    final updatedDetails = widget.details.asMap().entries.map((e) {
      return SalesDetailsModel(
        id: e.value.id,
        idRemision: e.value.idRemision,
        folioSale: e.value.folioSale,
        dateSale: e.value.dateSale,
        patient: e.value.patient,
        idOftalmico: e.value.idOftalmico,
        description: e.value.description,
        design: e.value.design,
        line: e.value.line,
        material: e.value.material,
        technology: e.value.technology,
        serie: e.value.serie,
        text: e.value.text,
        quantity: e.value.quantity,
        price: double.tryParse(_lensPriceCtrl[e.key].text),
        idMount: e.value.idMount,
        mount: e.value.mount,
        mountBrand: e.value.mountBrand,
        mountModel: e.value.mountModel,
        mountColor: e.value.mountColor,
        mountQuantity: e.value.mountQuantity,
        mountPrice: double.tryParse(_mountPriceCtrl[e.key].text),
        mountText: e.value.mountText,
        updatedDate: e.value.updatedDate,
      );
    }).toList();
    Navigator.of(context).pop();
    widget.ref
        .read(salesHistoryProvider.notifier)
        .updateSale(updatedSale, updatedDetails);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return ShadDialog(
      constraints: BoxConstraints(
        maxWidth: size.width * 0.65,
        minWidth: 340,
        maxHeight: size.height * 0.88,
      ),
      title: Text('Editar venta — ${widget.sale.patient ?? ''}'),
      description: Text(
        [
          if (widget.sale.folioSale != null && widget.sale.folioSale!.isNotEmpty)
            'Folio: ${widget.sale.folioSale!}',
          if (widget.sale.date != null && widget.sale.date!.isNotEmpty)
            widget.sale.date!,
        ].join(' · '),
      ),
      actions: [
        ShadButton.outline(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        ShadButton.outline(
          onPressed: _finalize,
          child: const Text(
            'Finalizar venta',
            style: TextStyle(color: Color(0xff16A34A)),
          ),
        ),
        ShadButton(
          onPressed: _save,
          child: const Text('Guardar cambios'),
        ),
      ],
      child: Flexible(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            spacing: 20,
            children: [
              // ── Artículos ─────────────────────────────────────
              if (widget.details.isNotEmpty)
                _Section(
                  label:
                      widget.details.length == 1
                          ? '1 artículo'
                          : '${widget.details.length} artículos',
                  child: Column(
                    spacing: 10,
                    children: widget.details.asMap().entries.map((e) {
                      final idx = e.key;
                      final detail = e.value;
                      final lensPrice =
                          double.tryParse(_lensPriceCtrl[idx].text) ?? 0;
                      final mountPrice =
                          double.tryParse(_mountPriceCtrl[idx].text) ?? 0;
                      final subtotal = lensPrice + mountPrice;
                      final itemLabel = detail.description ??
                          detail.text ??
                          detail.design ??
                          'Artículo ${idx + 1}';
                      return ShadCard(
                        padding: const EdgeInsets.all(14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          spacing: 12,
                          children: [
                            // Header
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    itemLabel,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xff18181B),
                                    ),
                                  ),
                                ),
                                if (widget.details.length > 1)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 3,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0xffEEECFE),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      '${idx + 1} / ${widget.details.length}',
                                      style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xff7A6BF5),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            // Price inputs
                            Row(
                              spacing: 12,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    spacing: 4,
                                    children: [
                                      const Text(
                                        'Precio lente',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                          color: Color(0xff52525B),
                                        ),
                                      ),
                                      ShadInput(
                                        controller: _lensPriceCtrl[idx],
                                        keyboardType: const TextInputType
                                            .numberWithOptions(decimal: true),
                                        placeholder: const Text('0.00'),
                                      ),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    spacing: 4,
                                    children: [
                                      const Text(
                                        'Precio montura',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                          color: Color(0xff52525B),
                                        ),
                                      ),
                                      ShadInput(
                                        controller: _mountPriceCtrl[idx],
                                        keyboardType: const TextInputType
                                            .numberWithOptions(decimal: true),
                                        placeholder: const Text('0.00'),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            // Subtotal
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xffEEECFE),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'Subtotal del artículo',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: Color(0xff5B4FD9),
                                    ),
                                  ),
                                  Text(
                                    subtotal.toCurrency(),
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xff5B4FD9),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),

              // ── Importes ──────────────────────────────────────
              _Section(
                label: 'Importes',
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xffFAFAFA),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xffE4E4E7)),
                  ),
                  child: Column(
                    spacing: 10,
                    children: [
                      // Read-only total
                      _SummaryRow(
                        label: 'Total',
                        value: _computedTotal.toCurrency(),
                      ),
                      // Editable discount
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Descuento',
                            style: TextStyle(
                              fontSize: 13,
                              color: Color(0xff3F3F46),
                            ),
                          ),
                          SizedBox(
                            width: 130,
                            child: ShadInput(
                              controller: _discountCtrl,
                              keyboardType: const TextInputType.numberWithOptions(
                                decimal: true,
                              ),
                              placeholder: const Text('0.00'),
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 1),
                      // Read-only total with discount
                      _SummaryRow(
                        label: 'Total con descuento',
                        value: _computedTotalWithDiscount.toCurrency(),
                        bold: true,
                      ),
                      const Divider(height: 1),
                      // Editable account
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'A cuenta',
                            style: TextStyle(
                              fontSize: 13,
                              color: Color(0xff3F3F46),
                            ),
                          ),
                          SizedBox(
                            width: 130,
                            child: ShadInput(
                              controller: _accountCtrl,
                              keyboardType: const TextInputType.numberWithOptions(
                                decimal: true,
                              ),
                              placeholder: const Text('0.00'),
                            ),
                          ),
                        ],
                      ),
                      // Read-only rest
                      _SummaryRow(
                        label: 'Resto',
                        value: _computedRest.toCurrency(),
                        valueColor:
                            _computedRest > 0
                                ? const Color(0xffDC2626)
                                : const Color(0xff16A34A),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Section wrapper ──────────────────────────────────────────────────────────

class _Section extends StatelessWidget {
  const _Section({required this.label, required this.child});
  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 10,
      children: [
        Text(
          label.toUpperCase(),
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: Color(0xff7A6BF5),
            letterSpacing: 0.5,
          ),
        ),
        const Divider(height: 1),
        child,
      ],
    );
  }
}

// ─── Summary row (read-only) ──────────────────────────────────────────────────

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.label,
    required this.value,
    this.bold = false,
    this.valueColor,
  });
  final String label;
  final String value;
  final bool bold;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    final style = TextStyle(
      fontSize: 13,
      fontWeight: bold ? FontWeight.w600 : FontWeight.normal,
      color: const Color(0xff3F3F46),
    );
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: style),
        Text(
          value,
          style: style.copyWith(color: valueColor ?? const Color(0xff18181B)),
        ),
      ],
    );
  }
}
