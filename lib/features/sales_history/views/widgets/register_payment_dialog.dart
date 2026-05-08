import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:oftal_web/core/data/providers/infrastructure_providers.dart';
import 'package:oftal_web/core/enums/enums.dart';
import 'package:oftal_web/features/sales_history/viewmodels/sales_history_provider.dart';
import 'package:oftal_web/shared/extensions/extensions.dart';
import 'package:oftal_web/shared/models/shared_models.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class RegisterPaymentDialog {
  Future<void> show(
    BuildContext context,
    WidgetRef ref,
    SalesModel sale,
  ) {
    return showShadDialog(
      context: context,
      builder: (ctx) => _RegisterPaymentContent(sale: sale),
    );
  }
}

class _RegisterPaymentContent extends ConsumerStatefulWidget {
  const _RegisterPaymentContent({required this.sale});
  final SalesModel sale;

  @override
  ConsumerState<_RegisterPaymentContent> createState() =>
      _RegisterPaymentContentState();
}

class _RegisterPaymentContentState
    extends ConsumerState<_RegisterPaymentContent> {
  late final TextEditingController _montoCtrl;
  late final TextEditingController _fechaCtrl;
  late final TextEditingController _notasCtrl;
  final _mask = MaskTextInputFormatter(
    mask: '####-##-##',
    filter: {'#': RegExp(r'[0-9]')},
  );
  PaymentMethodEnum _method = PaymentMethodEnum.efectivo;
  String? _montoError;

  @override
  void initState() {
    super.initState();
    _montoCtrl = TextEditingController();
    _fechaCtrl = TextEditingController(
      text: DateFormat('yyyy-MM-dd').format(DateTime.now()),
    );
    _notasCtrl = TextEditingController();
  }

  @override
  void dispose() {
    _montoCtrl.dispose();
    _fechaCtrl.dispose();
    _notasCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    final monto = double.tryParse(_montoCtrl.text);
    final resta = widget.sale.rest ?? 0;

    if (monto == null || monto <= 0) {
      setState(() => _montoError = 'Ingresa un monto válido');
      return;
    }
    if (monto > resta) {
      setState(
        () =>
            _montoError =
                'El abono no puede superar el saldo (${resta.toCurrency()})',
      );
      return;
    }
    final fechaValida = RegExp(
      r'^(19|20)\d{2}-(0[1-9]|1[0-2])-(0[1-9]|[12][0-9]|3[01])$',
    ).hasMatch(_fechaCtrl.text);
    if (!fechaValida) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ingresa una fecha válida (yyyy-MM-dd)')),
      );
      return;
    }

    context.pop();
    ref
        .read(salesHistoryProvider.notifier)
        .registerPayment(
          sale: widget.sale,
          monto: monto,
          fechaPago: _fechaCtrl.text,
          metodoPago: _method.value,
          notas: _notasCtrl.text.trim().isEmpty ? null : _notasCtrl.text.trim(),
        );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final sale = widget.sale;
    final resta = sale.rest ?? 0;

    return ShadDialog(
      constraints: BoxConstraints(
        maxWidth: size.width * 0.5,
        minWidth: 340,
        maxHeight: size.height * 0.88,
      ),
      closeIcon: ShadIconButton(
        icon: const Icon(Icons.close, size: 16),
        onPressed: () => context.pop(),
      ),
      title: const Text('Registrar abono'),
      description: Text(
        '${sale.patient ?? ''} · Folio ${sale.folioSale ?? ''}',
      ),
      actions: [
        ShadButton.outline(
          onPressed: () => context.pop(),
          child: const Text('Cancelar'),
        ),
        ShadButton(
          onPressed: _submit,
          child: const Text('Registrar abono'),
        ),
      ],
      child: Flexible(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 16,
            children: [
              // ── Resumen de saldo ──────────────────────────
              _BalanceSummary(sale: sale),

              // ── Historial de pagos anteriores ─────────────
              _PaymentHistory(idRemision: sale.id ?? ''),

              const Divider(height: 1),

              // ── Formulario de nuevo abono ─────────────────
              const _SectionLabel('Nuevo abono'),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 4,
                    children: [
                      const Text(
                        'Monto *',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Color(0xff52525B),
                        ),
                      ),
                      ShadInput(
                        controller: _montoCtrl,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        placeholder: Text(
                          'Máx. ${resta.toCurrency()}',
                        ),
                        onChanged: (_) => setState(() => _montoError = null),
                      ).constrained(width: 150),
                      if (_montoError != null)
                        Text(
                          _montoError!,
                          style: const TextStyle(
                            fontSize: 11,
                            color: Color(0xffEF4444),
                          ),
                        ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 4,
                    children: [
                      const Text(
                        'Fecha de pago *',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Color(0xff52525B),
                        ),
                      ),
                      ShadInput(
                        controller: _fechaCtrl,
                        inputFormatters: [_mask],
                        placeholder: const Text('yyyy-MM-dd'),
                      ).constrained(width: 140),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 4,
                    children: [
                      const Text(
                        'Método de pago',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Color(0xff52525B),
                        ),
                      ),
                      ShadSelect<PaymentMethodEnum>(
                        initialValue: _method,
                        selectedOptionBuilder: (ctx, v) => Text(v.label),
                        options:
                            PaymentMethodEnum.values
                                .map(
                                  (e) => ShadOption(
                                    value: e,
                                    child: Text(e.label),
                                  ),
                                )
                                .toList(),
                        onChanged: (v) {
                          if (v != null) setState(() => _method = v);
                        },
                      ).constrained(width: 160),
                    ],
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 4,
                children: [
                  const Text(
                    'Notas (opcional)',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Color(0xff52525B),
                    ),
                  ),
                  ShadInput(
                    controller: _notasCtrl,
                    maxLines: 2,
                    placeholder: const Text('Observaciones del pago...'),
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

// ─── Balance summary ──────────────────────────────────────────────────────────

class _BalanceSummary extends StatelessWidget {
  const _BalanceSummary({required this.sale});
  final SalesModel sale;

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
          _Row(
            'Total con descuento',
            sale.totalWithDiscount?.toCurrency() ?? '—',
          ),
          _Row(
            'Pagado hasta ahora',
            sale.account?.toCurrency() ?? '—',
            valueColor: const Color(0xff16A34A),
          ),
          const Divider(height: 1),
          _Row(
            'Saldo pendiente',
            sale.rest?.toCurrency() ?? '—',
            valueColor:
                (sale.rest ?? 0) > 0
                    ? const Color(0xffDC2626)
                    : const Color(0xff16A34A),
            bold: true,
          ),
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row(this.label, this.value, {this.valueColor, this.bold = false});
  final String label;
  final String value;
  final Color? valueColor;
  final bool bold;

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
        Text(value, style: style.copyWith(color: valueColor)),
      ],
    );
  }
}

// ─── Payment history ──────────────────────────────────────────────────────────

class _PaymentHistory extends ConsumerWidget {
  const _PaymentHistory({required this.idRemision});
  final String idRemision;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FutureBuilder(
      future: ref
          .read(paymentRepositoryProvider)
          .getPaymentsByRemision(idRemision),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox.shrink();
        final result = snapshot.data!;
        return result.fold(
          (_) => const SizedBox.shrink(),
          (payments) {
            if (payments.isEmpty) return const SizedBox.shrink();
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 8,
              children: [
                _SectionLabel('Abonos anteriores (${payments.length})'),
                ...payments.map(
                  (p) => Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xffF0FDF4),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: const Color(0xffBBF7D0)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          spacing: 2,
                          children: [
                            Text(
                              p.fechaPago,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Color(0xff15803D),
                              ),
                            ),
                            if (p.metodoPago != null)
                              Text(
                                p.metodoPago!,
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: Color(0xff52525B),
                                ),
                              ),
                          ],
                        ),
                        Text(
                          p.monto.toCurrency(),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Color(0xff16A34A),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const Divider(height: 1),
              ],
            );
          },
        );
      },
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: Color(0xff7A6BF5),
        letterSpacing: 0.5,
      ),
    );
  }
}
