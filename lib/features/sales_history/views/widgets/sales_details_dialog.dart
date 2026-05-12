import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:oftal_web/core/data/providers/infrastructure_providers.dart';
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
      builder: (context) {
        final size = MediaQuery.sizeOf(context);
        return ShadDialog(
          constraints: BoxConstraints(
            maxWidth: (size.width * 0.85).clamp(320, 620),
            maxHeight: size.height * 0.88,
          ),
          closeIcon: ShadIconButton(
            icon: const Icon(Icons.close, size: 16),
            onPressed: () {
              ref
                  .read(salesHistoryProvider.notifier)
                  .clearSaleSelectedForDetails();
              context.pop();
            },
          ),
          title: Text(sale.patient ?? 'Detalles de la venta'),
          description: Text(
            [
              if (sale.date != null && sale.date!.isNotEmpty) sale.date!,
              if (sale.branch != null && sale.branch!.isNotEmpty) sale.branch!,
              if (sale.authorName != null && sale.authorName!.isNotEmpty)
                'Vendedor: ${sale.authorName!}',
            ].join(' · '),
          ),
          actions: [
            if ((sale.rest ?? 0) > 0)
              ShadButton(
                backgroundColor: const Color(0xff16A34A),
                onPressed: () {
                  ref
                      .read(salesHistoryProvider.notifier)
                      .clearSaleSelectedForDetails();
                  context.pop();
                  ref
                      .read(salesHistoryProvider.notifier)
                      .finalizeSale(sale);
                },
                child: const Row(
                  spacing: 6,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.check_circle_outline, size: 16),
                    Text('Finalizar venta'),
                  ],
                ),
              ),
            ShadButton.outline(
              onPressed: () {
                ref
                    .read(salesHistoryProvider.notifier)
                    .clearSaleSelectedForDetails();
                context.pop();
              },
              child: const Text('Cerrar'),
            ),
          ],
          child: Flexible(
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                spacing: 20,
                children: [
                  // ── Resumen financiero ────────────────────────
                  _FinancialSummary(sale: sale, itemCount: saleDetails.length),

                  // ── Historial de abonos ──────────────────────
                  if (sale.id != null && sale.id!.isNotEmpty)
                    _PaymentHistorySection(sale: sale),

                  // ── Artículos ────────────────────────────────
                  if (saleDetails.isNotEmpty)
                    _Section(
                      label:
                          saleDetails.length == 1
                              ? '1 artículo'
                              : '${saleDetails.length} artículos',
                      child: Column(
                        spacing: 10,
                        children:
                            saleDetails.asMap().entries.map((e) {
                              return _DetailCard(
                                detail: e.value,
                                index: e.key + 1,
                                total: saleDetails.length,
                              );
                            }).toList(),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

// ─── Financial summary ────────────────────────────────────────────────────────

class _FinancialSummary extends StatelessWidget {
  const _FinancialSummary({required this.sale, required this.itemCount});
  final SalesModel sale;
  final int itemCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xffFAFAFA),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xffE4E4E7)),
      ),
      child: Column(
        spacing: 8,
        children: [
          _SummaryRow(
            label: 'Total sin descuento',
            value: sale.total?.toCurrency() ?? '—',
          ),
          if ((sale.discount ?? 0) > 0) ...[
            _SummaryRow(
              label: 'Descuento',
              value: sale.discount?.toCurrency() ?? '—',
              valueColor: const Color(0xffDC2626),
            ),
            const Divider(height: 1),
            _SummaryRow(
              label: 'Total con descuento',
              value: sale.totalWithDiscount?.toCurrency() ?? '—',
              bold: true,
            ),
          ],
          if ((sale.discount ?? 0) == 0)
            _SummaryRow(
              label: 'Total',
              value: sale.total?.toCurrency() ?? '—',
              bold: true,
            ),
        ],
      ),
    );
  }
}

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

// ─── Single detail card ───────────────────────────────────────────────────────

class _DetailCard extends StatelessWidget {
  const _DetailCard({
    required this.detail,
    required this.index,
    required this.total,
  });
  final SalesDetailsModel detail;
  final int index;
  final int total;

  bool _has(String? v) => v != null && v.isNotEmpty;
  bool _hasNum(num? v) => v != null && v != 0;

  @override
  Widget build(BuildContext context) {
    final hasLens = _has(detail.design) ||
        _has(detail.line) ||
        _has(detail.material) ||
        _has(detail.technology) ||
        _has(detail.serie) ||
        _has(detail.text) ||
        _has(detail.quantity) ||
        _hasNum(detail.price);

    final hasMount = _has(detail.mount) ||
        _has(detail.mountBrand) ||
        _has(detail.mountModel) ||
        _has(detail.mountColor) ||
        _has(detail.mountQuantity) ||
        _hasNum(detail.mountPrice) ||
        _has(detail.mountText);

    return ShadCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 12,
        children: [
          // ── Card header ──────────────────────────────────
          Row(
            children: [
              Expanded(
                child: Row(
                  spacing: 12,
                  children: [
                    if (_has(detail.dateSale))
                      _Chip(
                        icon: Icons.calendar_today_outlined,
                        label: detail.dateSale!,
                      ),
                    if (_has(detail.folioSale))
                      _Chip(
                        icon: Icons.receipt_outlined,
                        label: detail.folioSale!,
                      ),
                  ],
                ),
              ),
              if (total > 1)
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
                    '$index / $total',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Color(0xff7A6BF5),
                    ),
                  ),
                ),
            ],
          ),

          // ── Precio total del ítem ─────────────────────────
          if (_hasNum(detail.price) || _hasNum(detail.mountPrice))
            _PriceRow(
              lensPrice: detail.price,
              mountPrice: detail.mountPrice,
            ),

          // ── Lente ────────────────────────────────────────
          if (hasLens) ...[
            _SubSectionLabel('Lente'),
            _FieldGrid(
              fields: [
                if (_has(detail.description))
                  _Field('Descripción', detail.description!),
                if (_has(detail.design)) _Field('Diseño', detail.design!),
                if (_has(detail.line)) _Field('Línea', detail.line!),
                if (_has(detail.material)) _Field('Material', detail.material!),
                if (_has(detail.technology))
                  _Field('Tecnología', detail.technology!),
                if (_has(detail.serie)) _Field('Serie', detail.serie!),
                if (_has(detail.text)) _Field('Texto', detail.text!),
                if (_has(detail.quantity))
                  _Field('Cantidad', detail.quantity!),
                if (_hasNum(detail.price))
                  _Field('Precio', detail.price!.toCurrency()),
              ],
            ),
          ],

          // ── Montura ──────────────────────────────────────
          if (hasMount) ...[
            _SubSectionLabel('Montura'),
            _FieldGrid(
              fields: [
                if (_has(detail.mount)) _Field('Montura', detail.mount!),
                if (_has(detail.mountBrand))
                  _Field('Marca', detail.mountBrand!),
                if (_has(detail.mountModel))
                  _Field('Modelo', detail.mountModel!),
                if (_has(detail.mountColor))
                  _Field('Color', detail.mountColor!),
                if (_has(detail.mountQuantity))
                  _Field('Cantidad', detail.mountQuantity!),
                if (_hasNum(detail.mountPrice))
                  _Field('Precio', detail.mountPrice!.toCurrency()),
                if (_has(detail.mountText))
                  _Field('Texto', detail.mountText!),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

// ─── Price summary row inside card ───────────────────────────────────────────

class _PriceRow extends StatelessWidget {
  const _PriceRow({this.lensPrice, this.mountPrice});
  final double? lensPrice;
  final double? mountPrice;

  @override
  Widget build(BuildContext context) {
    final total = (lensPrice ?? 0) + (mountPrice ?? 0);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xffEEECFE),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
            total.toCurrency(),
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: Color(0xff5B4FD9),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Field grid (2 columns) ───────────────────────────────────────────────────

class _FieldData {
  final String label;
  final String value;
  const _FieldData(this.label, this.value);
}

// ignore: non_constant_identifier_names
_FieldData _Field(String label, String value) => _FieldData(label, value);

class _FieldGrid extends StatelessWidget {
  const _FieldGrid({required this.fields});
  final List<_FieldData> fields;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 24,
      runSpacing: 6,
      children:
          fields.map((f) {
            return Row(
              mainAxisSize: MainAxisSize.min,
              spacing: 4,
              children: [
                Text(
                  '${f.label}:',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xff52525B),
                  ),
                ),
                Text(
                  f.value,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xff18181B),
                  ),
                ),
              ],
            );
          }).toList(),
    );
  }
}

// ─── Sub-section label ────────────────────────────────────────────────────────

class _SubSectionLabel extends StatelessWidget {
  const _SubSectionLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: Color(0xff7A6BF5),
        letterSpacing: 0.5,
      ),
    );
  }
}

// ─── Payment history section ──────────────────────────────────────────────────

class _PaymentHistorySection extends ConsumerWidget {
  const _PaymentHistorySection({required this.sale});
  final SalesModel sale;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FutureBuilder(
      future: ref
          .read(paymentRepositoryProvider)
          .getPaymentsByRemision(sale.id!),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox.shrink();
        return snapshot.data!.fold(
          (_) => const SizedBox.shrink(),
          (payments) {
            final pagosSum = payments.fold(0.0, (s, p) => s + p.monto);
            final initialAccount = (sale.account ?? 0) - pagosSum;
            final hasInitial = initialAccount > 0.001;
            final totalMovements = (hasInitial ? 1 : 0) + payments.length;
            if (totalMovements == 0) return const SizedBox.shrink();

            return _Section(
              label: 'Historial de pagos',
              child: Column(
                spacing: 0,
                children: [
                  // ── Pago inicial ──────────────────────────────
                  if (hasInitial) ...[
                    _PaymentRow(
                      fecha: sale.date ?? '—',
                      etiqueta: 'Pago inicial',
                      monto: initialAccount,
                      isInitial: true,
                    ),
                    const _TimelineDivider(),
                  ],

                  // ── Abonos posteriores ────────────────────────
                  ...payments.asMap().entries.map((e) {
                    final isLast = e.key == payments.length - 1;
                    return Column(
                      children: [
                        _PaymentRow(
                          fecha: e.value.fechaPago,
                          etiqueta: e.value.notas ?? e.value.metodoPago ?? 'Abono',
                          metodo: e.value.notas != null ? e.value.metodoPago : null,
                          monto: e.value.monto,
                        ),
                        if (!isLast) const _TimelineDivider(),
                      ],
                    );
                  }),

                  // ── Totales ───────────────────────────────────
                  const SizedBox(height: 12),
                  const Divider(height: 1),
                  const SizedBox(height: 10),
                  _TotalsRow(
                    totalConDescuento: sale.totalWithDiscount ?? 0,
                    totalAbonado: sale.account ?? 0,
                    saldoPendiente: sale.rest ?? 0,
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class _PaymentRow extends StatelessWidget {
  const _PaymentRow({
    required this.fecha,
    required this.etiqueta,
    required this.monto,
    this.metodo,
    this.isInitial = false,
  });
  final String fecha;
  final String etiqueta;
  final String? metodo;
  final double monto;
  final bool isInitial;

  @override
  Widget build(BuildContext context) {
    final color = isInitial ? const Color(0xff2563EB) : const Color(0xff16A34A);
    final bg = isInitial ? const Color(0xffEFF6FF) : const Color(0xffF0FDF4);
    final border = isInitial ? const Color(0xffBFDBFE) : const Color(0xffBBF7D0);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: border),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 2,
              children: [
                Text(
                  fecha,
                  style: TextStyle(
                    fontSize: 11,
                    color: color.withValues(alpha: 0.8),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  etiqueta,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
                if (metodo != null)
                  Text(
                    metodo!,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xff71717A),
                    ),
                  ),
              ],
            ),
          ),
          Text(
            monto.toCurrency(),
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _TimelineDivider extends StatelessWidget {
  const _TimelineDivider();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const SizedBox(width: 20),
        Container(
          width: 1,
          height: 12,
          color: const Color(0xffD4D4D8),
        ),
      ],
    );
  }
}

class _TotalsRow extends StatelessWidget {
  const _TotalsRow({
    required this.totalConDescuento,
    required this.totalAbonado,
    required this.saldoPendiente,
  });
  final double totalConDescuento;
  final double totalAbonado;
  final double saldoPendiente;

  @override
  Widget build(BuildContext context) {
    final isPaid = saldoPendiente <= 0;
    return Column(
      spacing: 6,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Total abonado',
              style: TextStyle(fontSize: 12, color: Color(0xff52525B)),
            ),
            Text(
              totalAbonado.toCurrency(),
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xff16A34A),
              ),
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Saldo pendiente',
              style: TextStyle(fontSize: 12, color: Color(0xff52525B)),
            ),
            Text(
              isPaid ? 'Liquidado' : saldoPendiente.toCurrency(),
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isPaid
                    ? const Color(0xff16A34A)
                    : const Color(0xffDC2626),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ─── Info chip ────────────────────────────────────────────────────────────────

class _Chip extends StatelessWidget {
  const _Chip({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      spacing: 4,
      children: [
        Icon(icon, size: 13, color: const Color(0xff71717A)),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Color(0xff52525B),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
