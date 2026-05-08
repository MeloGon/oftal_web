import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:oftal_web/core/enums/enums.dart';
import 'package:oftal_web/features/settings/viewmodels/payments_report_provider.dart';
import 'package:oftal_web/features/settings/viewmodels/payments_report_state.dart';
import 'package:oftal_web/shared/extensions/extensions.dart';
import 'package:oftal_web/shared/models/daily_payment_model.dart';
import 'package:oftal_web/shared/models/snackbar_config_model.dart';
import 'package:oftal_web/shared/widgets/widgets.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class PaymentsReportView extends ConsumerWidget {
  const PaymentsReportView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(paymentsReportProvider);
    final notifier = ref.read(paymentsReportProvider.notifier);

    ref.listen(paymentsReportProvider, (previous, next) {
      if (next.errorMessage.isNotEmpty &&
          previous?.errorMessage != next.errorMessage) {
        _showSnackbar(context, next.snackbarConfig, next.errorMessage);
        Future.microtask(notifier.clearErrorMessage);
      }
    });

    final payments = state.payments;
    final total = payments.fold(0.0, (sum, p) => sum + p.monto);
    final byMethod = _groupByMethod(payments);

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 20,
        children: [
          // ─── Header ──────────────────────────────────────────
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              IconButton(
                onPressed: () => context.pop(),
                icon: const Icon(Icons.arrow_back_ios_rounded, size: 16),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.white,
                  side: const BorderSide(color: Color(0xffE4E4E7)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 2,
                  children: [
                    Text(
                      'Reportes · Ingresos',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Color(0xff18181B),
                      ),
                    ),
                    Text(
                      'Pagos y abonos recibidos según el período seleccionado',
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xff71717A),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // ─── Filter tabs ─────────────────────────────────────
          _PeriodFilterBar(state: state, notifier: notifier),

          // ─── Summary + table ──────────────────────────────────
          LoadingOverlay(
            isLoading: state.isLoading,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 16,
              children: [
                _SummaryRow(total: total, byMethod: byMethod),
                ShadCard(
                  padding: EdgeInsets.zero,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
                        child: Text(
                          'Detalle de ingresos  (${payments.length})',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Color(0xff18181B),
                          ),
                        ),
                      ),
                      const Divider(height: 1, color: Color(0xffF4F4F5)),
                      payments.isEmpty
                          ? const _EmptyState()
                          : _PaymentsTable(payments: payments),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Map<String, double> _groupByMethod(List<DailyPaymentModel> payments) {
    final map = <String, double>{};
    for (final p in payments) {
      final key = p.metodoPago ?? 'otro';
      map[key] = (map[key] ?? 0) + p.monto;
    }
    return map;
  }
}

// ─── Period filter bar ────────────────────────────────────────────────────────

class _PeriodFilterBar extends StatelessWidget {
  const _PeriodFilterBar({required this.state, required this.notifier});

  final PaymentsReportState state;
  final PaymentsReport notifier;

  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: 16,
      children: [
        // Segmented tabs
        Container(
          decoration: BoxDecoration(
            color: const Color(0xffF4F4F5),
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.all(3),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: ReportPeriodFilter.values.map((f) {
              final selected = state.filter == f;
              return GestureDetector(
                onTap: () => notifier.selectFilter(f),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: selected ? Colors.white : Colors.transparent,
                    borderRadius: BorderRadius.circular(6),
                    boxShadow: selected
                        ? [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.06),
                              blurRadius: 4,
                              offset: const Offset(0, 1),
                            ),
                          ]
                        : [],
                  ),
                  child: Text(
                    f.label,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: selected
                          ? FontWeight.w600
                          : FontWeight.w400,
                      color: selected
                          ? const Color(0xff18181B)
                          : const Color(0xff71717A),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),

        // Date controls depending on mode
        _DateControls(state: state, notifier: notifier),
      ],
    );
  }
}

class _DateControls extends StatelessWidget {
  const _DateControls({required this.state, required this.notifier});

  final PaymentsReportState state;
  final PaymentsReport notifier;

  @override
  Widget build(BuildContext context) {
    return switch (state.filter) {
      ReportPeriodFilter.day => _DayPicker(
          selected: state.selectedDay,
          onPicked: notifier.selectDay,
        ),
      ReportPeriodFilter.month => _MonthPicker(
          selected: state.selectedMonth,
          onPicked: notifier.selectMonth,
        ),
      ReportPeriodFilter.range => _RangePicker(
          start: state.rangeStart,
          end: state.rangeEnd,
          onStartPicked: notifier.selectRangeStart,
          onEndPicked: notifier.selectRangeEnd,
        ),
    };
  }
}

// ─── Day picker ───────────────────────────────────────────────────────────────

class _DayPicker extends StatelessWidget {
  const _DayPicker({required this.selected, required this.onPicked});

  final DateTime selected;
  final void Function(DateTime) onPicked;

  @override
  Widget build(BuildContext context) {
    return ShadButton.outline(
      onPressed: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: selected,
          firstDate: DateTime(2020),
          lastDate: DateTime.now(),
          locale: const Locale('es', 'MX'),
        );
        if (picked != null) onPicked(picked);
      },
      child: Row(
        spacing: 8,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.calendar_today_rounded, size: 14),
          Text(DateFormat('dd/MM/yyyy').format(selected)),
        ],
      ),
    );
  }
}

// ─── Month picker ─────────────────────────────────────────────────────────────

class _MonthPicker extends StatelessWidget {
  const _MonthPicker({required this.selected, required this.onPicked});

  final DateTime selected;
  final void Function(DateTime) onPicked;

  @override
  Widget build(BuildContext context) {
    return ShadButton.outline(
      onPressed: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: selected,
          firstDate: DateTime(2020),
          lastDate: DateTime.now(),
          locale: const Locale('es', 'MX'),
          initialDatePickerMode: DatePickerMode.year,
        );
        if (picked != null) onPicked(picked);
      },
      child: Row(
        spacing: 8,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.calendar_month_rounded, size: 14),
          Text(DateFormat('MMMM yyyy', 'es_MX').format(selected)),
        ],
      ),
    );
  }
}

// ─── Range picker ─────────────────────────────────────────────────────────────

class _RangePicker extends StatelessWidget {
  const _RangePicker({
    required this.start,
    required this.end,
    required this.onStartPicked,
    required this.onEndPicked,
  });

  final DateTime start;
  final DateTime end;
  final void Function(DateTime) onStartPicked;
  final void Function(DateTime) onEndPicked;

  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: 8,
      mainAxisSize: MainAxisSize.min,
      children: [
        ShadButton.outline(
          onPressed: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: start,
              firstDate: DateTime(2020),
              lastDate: DateTime.now(),
              locale: const Locale('es', 'MX'),
            );
            if (picked != null) onStartPicked(picked);
          },
          child: Row(
            spacing: 8,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.calendar_today_rounded, size: 14),
              Text('Desde: ${DateFormat('dd/MM/yyyy').format(start)}'),
            ],
          ),
        ),
        const Icon(Icons.arrow_forward_rounded, size: 14, color: Color(0xff71717A)),
        ShadButton.outline(
          onPressed: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: end,
              firstDate: start,
              lastDate: DateTime.now(),
              locale: const Locale('es', 'MX'),
            );
            if (picked != null) onEndPicked(picked);
          },
          child: Row(
            spacing: 8,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.calendar_today_rounded, size: 14),
              Text('Hasta: ${DateFormat('dd/MM/yyyy').format(end)}'),
            ],
          ),
        ),
      ],
    );
  }
}

// ─── Summary row ─────────────────────────────────────────────────────────────

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({required this.total, required this.byMethod});

  final double total;
  final Map<String, double> byMethod;

  static const _methodMeta = <String, _MethodMeta>{
    'efectivo': _MethodMeta(
      label: 'Efectivo',
      icon: Icons.payments_outlined,
      color: Color(0xff22C55E),
      bg: Color(0xffDCFCE7),
    ),
    'tarjeta': _MethodMeta(
      label: 'Tarjeta',
      icon: Icons.credit_card_rounded,
      color: Color(0xff3B82F6),
      bg: Color(0xffDBEAFE),
    ),
    'transferencia': _MethodMeta(
      label: 'Transferencia',
      icon: Icons.swap_horiz_rounded,
      color: Color(0xff8B5CF6),
      bg: Color(0xffEDE9FE),
    ),
    'nomina': _MethodMeta(
      label: 'Nómina',
      icon: Icons.account_balance_outlined,
      color: Color(0xffF59E0B),
      bg: Color(0xffFEF3C7),
    ),
    'otro': _MethodMeta(
      label: 'Otro',
      icon: Icons.more_horiz_rounded,
      color: Color(0xff6B7280),
      bg: Color(0xffF3F4F6),
    ),
  };

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        _MetricCard(
          label: 'Total ingresado',
          value: total.toCurrency(),
          icon: Icons.trending_up_rounded,
          iconColor: const Color(0xff0EA5E9),
          iconBg: const Color(0xffE0F2FE),
          isTotal: true,
        ),
        ...byMethod.entries.map((entry) {
          final meta = _methodMeta[entry.key] ?? _methodMeta['otro']!;
          return _MetricCard(
            label: meta.label,
            value: entry.value.toCurrency(),
            icon: meta.icon,
            iconColor: meta.color,
            iconBg: meta.bg,
          );
        }),
      ],
    );
  }
}

class _MethodMeta {
  const _MethodMeta({
    required this.label,
    required this.icon,
    required this.color,
    required this.bg,
  });
  final String label;
  final IconData icon;
  final Color color;
  final Color bg;
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    this.isTotal = false,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final bool isTotal;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: 180),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isTotal
              ? iconColor.withValues(alpha: 0.3)
              : const Color(0xffE4E4E7),
          width: isTotal ? 1.5 : 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: 12,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 18, color: iconColor),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 2,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey.shade500,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: isTotal ? iconColor : const Color(0xff18181B),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Payments table ───────────────────────────────────────────────────────────

class _PaymentsTable extends StatelessWidget {
  const _PaymentsTable({required this.payments});

  final List<DailyPaymentModel> payments;

  static const _methodLabels = <String, String>{
    'efectivo': 'Efectivo',
    'tarjeta': 'Tarjeta',
    'transferencia': 'Transferencia',
    'nomina': 'Nómina',
    'otro': 'Otro',
  };

  static const _methodColors = <String, Color>{
    'efectivo': Color(0xff22C55E),
    'tarjeta': Color(0xff3B82F6),
    'transferencia': Color(0xff8B5CF6),
    'nomina': Color(0xffF59E0B),
    'otro': Color(0xff6B7280),
  };

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        headingRowColor: WidgetStateProperty.all(const Color(0xffFAFAFA)),
        headingRowHeight: 38,
        dataRowMinHeight: 44,
        dataRowMaxHeight: 52,
        columnSpacing: 20,
        horizontalMargin: 16,
        columns: const [
          DataColumn(label: _ColHeader('Fecha')),
          DataColumn(label: _ColHeader('Paciente')),
          DataColumn(label: _ColHeader('Folio')),
          DataColumn(label: _ColHeader('Método de pago')),
          DataColumn(label: _ColHeader('Notas')),
          DataColumn(label: _ColHeader('Monto'), numeric: true),
        ],
        rows: payments.map((p) {
          final method = p.metodoPago ?? 'otro';
          final methodLabel = _methodLabels[method] ?? method;
          final methodColor =
              _methodColors[method] ?? const Color(0xff6B7280);

          return DataRow(
            cells: [
              DataCell(
                Text(
                  p.fechaPago,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xff52525B),
                  ),
                ),
              ),
              DataCell(
                Text(
                  p.paciente ?? '—',
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xff18181B),
                  ),
                ),
              ),
              DataCell(
                Text(
                  p.folioRemision ?? p.idRemision,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xff52525B),
                    fontFamily: 'monospace',
                  ),
                ),
              ),
              DataCell(
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: methodColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    methodLabel,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: methodColor,
                    ),
                  ),
                ),
              ),
              DataCell(
                Text(
                  p.notas?.isNotEmpty == true ? p.notas! : '—',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xff71717A),
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                ),
              ),
              DataCell(
                Text(
                  p.monto.toCurrency(),
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xff18181B),
                  ),
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }
}

class _ColHeader extends StatelessWidget {
  const _ColHeader(this.text);
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

// ─── Empty state ──────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Center(
        child: Column(
          spacing: 8,
          children: [
            Icon(Icons.inbox_outlined, size: 40, color: Colors.grey.shade300),
            Text(
              'Sin ingresos en el período seleccionado',
              style: TextStyle(fontSize: 13, color: Colors.grey.shade400),
            ),
          ],
        ),
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
