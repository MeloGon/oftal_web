import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:oftal_web/core/enums/snackbar_enum.dart';
import 'package:oftal_web/features/settings/viewmodels/sales_by_seller_provider.dart';
import 'package:oftal_web/features/settings/viewmodels/sales_by_seller_state.dart';
import 'package:oftal_web/shared/extensions/extensions.dart';
import 'package:oftal_web/shared/models/sales_model.dart';
import 'package:oftal_web/shared/models/snackbar_config_model.dart';
import 'package:oftal_web/shared/widgets/widgets.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class SalesBySellerView extends ConsumerWidget {
  const SalesBySellerView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(salesBySellerProvider);
    final notifier = ref.read(salesBySellerProvider.notifier);

    ref.listenLoading(
      salesBySellerProvider.select((s) => s.isLoading),
      context,
    );

    ref.listen(salesBySellerProvider, (previous, next) {
      if (next.errorMessage.isNotEmpty &&
          previous?.errorMessage != next.errorMessage) {
        CustomSnackbar().show(
          context,
          next.snackbarConfig ??
              SnackbarConfigModel(title: 'Error', type: SnackbarEnum.error),
          next.errorMessage,
        );
        Future.microtask(notifier.clearErrorMessage);
      }
    });

    final allSellers = state.availableSellers;
    final allBySeller = _groupBySeller(state.sales);
    final bySeller = Map.of(allBySeller)
      ..removeWhere((seller, _) => !state.isSellerActive(seller));

    final sellerTotals = Map.fromEntries(
      allBySeller.entries.map((e) => MapEntry(
        e.key,
        e.value.fold<double>(
          0,
          (sum, s) => sum + (s.totalWithDiscount ?? s.total ?? 0),
        ),
      )),
    );

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 20,
        children: [
          // ─── Header ──────────────────────────────────────────
          Row(
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
                      'Reportes · Ventas por vendedor',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Color(0xff18181B),
                      ),
                    ),
                    Text(
                      'Ventas agrupadas por vendedor según el mes seleccionado',
                      style: TextStyle(fontSize: 12, color: Color(0xff71717A)),
                    ),
                  ],
                ),
              ),
              if (sellerTotals.isNotEmpty)
                ShadButton.outline(
                  onPressed: () => showDialog(
                    context: context,
                    builder: (_) => _CommissionsDialog(
                      sellerTotals: sellerTotals,
                    ),
                  ),
                  child: const Row(
                    spacing: 8,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.calculate_outlined, size: 16),
                      Text('Cálculo de comisiones'),
                    ],
                  ),
                ),
            ],
          ),

          // ─── Month filter ─────────────────────────────────────
          _MonthPicker(
            selected: state.selectedMonth,
            onPicked: notifier.selectMonth,
          ),

          // ─── Seller chips ─────────────────────────────────────
          if (allSellers.isNotEmpty)
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: allSellers.map(
                (seller) => _SellerChip(
                  label: seller,
                  selected: state.isSellerActive(seller),
                  onTap: () => notifier.toggleSeller(seller),
                ),
              ).toList(),
            ),

          // ─── Content ──────────────────────────────────────────
          Expanded(
            child: SingleChildScrollView(
              child: bySeller.isEmpty && !state.isLoading
                  ? const _EmptyState()
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: 24,
                      children: bySeller.entries.map((entry) {
                        return _SellerSection(
                          sellerName: entry.key,
                          sales: entry.value,
                        );
                      }).toList(),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Map<String, List<SalesModel>> _groupBySeller(List<SalesModel> sales) {
    final map = <String, List<SalesModel>>{};
    for (final sale in sales) {
      final raw = sale.authorName?.trim() ?? '';
      final key = raw.isNotEmpty ? _toTitleCase(raw) : 'Sin vendedor';
      map.putIfAbsent(key, () => []).add(sale);
    }
    return Map.fromEntries(
      map.entries.toList()..sort((a, b) => a.key.compareTo(b.key)),
    );
  }

  static String _toTitleCase(String name) {
    return name.split(' ').map((w) {
      if (w.isEmpty) return w;
      return w[0].toUpperCase() + w.substring(1).toLowerCase();
    }).join(' ');
  }
}

// ─── Month picker ─────────────────────────────────────────────────────────────

// ─── Seller chip ──────────────────────────────────────────────────────────────

class _SellerChip extends StatelessWidget {
  const _SellerChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? const Color(0xff7A6BF5) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected
                ? const Color(0xff7A6BF5)
                : const Color(0xffE4E4E7),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: selected ? Colors.white : const Color(0xff52525B),
          ),
        ),
      ),
    );
  }
}

// ─── Month picker ─────────────────────────────────────────────────────────────

class _MonthPicker extends StatelessWidget {
  const _MonthPicker({required this.selected, required this.onPicked});

  final DateTime selected;
  final void Function(DateTime) onPicked;

  static const _months = [
    'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
    'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre',
  ];

  @override
  Widget build(BuildContext context) {
    return ShadButton.outline(
      onPressed: () async {
        final picked = await showDialog<DateTime>(
          context: context,
          builder: (_) => _MonthPickerDialog(initial: selected),
        );
        if (picked != null) onPicked(picked);
      },
      child: Row(
        spacing: 8,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.calendar_month_rounded, size: 14),
          Text(
            '${_months[selected.month - 1]} ${selected.year}',
          ),
        ],
      ),
    );
  }
}

class _MonthPickerDialog extends StatefulWidget {
  const _MonthPickerDialog({required this.initial});
  final DateTime initial;

  @override
  State<_MonthPickerDialog> createState() => _MonthPickerDialogState();
}

class _MonthPickerDialogState extends State<_MonthPickerDialog> {
  static const _months = [
    'Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun',
    'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic',
  ];

  late int _year;
  late int _selectedMonth;
  final int _minYear = 2020;
  final int _maxYear = DateTime.now().year;

  @override
  void initState() {
    super.initState();
    _year = widget.initial.year;
    _selectedMonth = widget.initial.month;
  }

  bool _isDisabled(int month) {
    final now = DateTime.now();
    return _year == now.year && month > now.month;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          spacing: 16,
          children: [
            // ── Year navigation ───────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  onPressed: _year > _minYear
                      ? () => setState(() => _year--)
                      : null,
                  icon: const Icon(Icons.chevron_left_rounded),
                  style: IconButton.styleFrom(
                    side: const BorderSide(color: Color(0xffE4E4E7)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                Text(
                  '$_year',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xff18181B),
                  ),
                ),
                IconButton(
                  onPressed: _year < _maxYear
                      ? () => setState(() => _year++)
                      : null,
                  icon: const Icon(Icons.chevron_right_rounded),
                  style: IconButton.styleFrom(
                    side: const BorderSide(color: Color(0xffE4E4E7)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),

            // ── Month grid ────────────────────────────────────
            GridView.count(
              crossAxisCount: 4,
              shrinkWrap: true,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              childAspectRatio: 1.6,
              children: List.generate(12, (i) {
                final month = i + 1;
                final isSelected =
                    _selectedMonth == month && _year == widget.initial.year;
                final disabled = _isDisabled(month);
                return GestureDetector(
                  onTap: disabled
                      ? null
                      : () {
                          Navigator.of(context)
                              .pop(DateTime(_year, month));
                        },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 120),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xff7A6BF5)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isSelected
                            ? const Color(0xff7A6BF5)
                            : const Color(0xffE4E4E7),
                      ),
                    ),
                    child: Center(
                      child: Text(
                        _months[i],
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.w400,
                          color: disabled
                              ? const Color(0xffD4D4D8)
                              : isSelected
                                  ? Colors.white
                                  : const Color(0xff18181B),
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Seller section ───────────────────────────────────────────────────────────

class _SellerSection extends StatelessWidget {
  const _SellerSection({required this.sellerName, required this.sales});

  final String sellerName;
  final List<SalesModel> sales;

  @override
  Widget build(BuildContext context) {
    final total = sales.fold<double>(
      0,
      (sum, s) => sum + (s.totalWithDiscount ?? s.total ?? 0),
    );
    final totalAccount = sales.fold<double>(
      0,
      (sum, s) => sum + (s.account ?? 0),
    );
    final totalRest = sales.fold<double>(
      0,
      (sum, s) => sum + (s.rest ?? 0),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 12,
      children: [
        // ── Seller header ─────────────────────────────────────
        Row(
          spacing: 10,
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: const Color(0xffEEECFE),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.person_outline_rounded,
                size: 16,
                color: Color(0xff7A6BF5),
              ),
            ),
            Expanded(
              child: Text(
                sellerName,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Color(0xff18181B),
                ),
              ),
            ),
            Text(
              '${sales.length} venta${sales.length == 1 ? '' : 's'}',
              style: const TextStyle(fontSize: 12, color: Color(0xff71717A)),
            ),
          ],
        ),

        // ── Summary cards ─────────────────────────────────────
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _SummaryCard(
              label: 'Total ventas',
              value: total.toCurrency(),
              color: const Color(0xff7A6BF5),
              bg: const Color(0xffEEECFE),
              icon: Icons.sell_outlined,
            ),
            _SummaryCard(
              label: 'A cuenta',
              value: totalAccount.toCurrency(),
              color: const Color(0xff22C55E),
              bg: const Color(0xffDCFCE7),
              icon: Icons.payments_outlined,
            ),
            _SummaryCard(
              label: 'Saldo pendiente',
              value: totalRest.toCurrency(),
              color: const Color(0xffEF4444),
              bg: const Color(0xffFEE2E2),
              icon: Icons.pending_outlined,
            ),
          ],
        ),

        // ── Sales table ───────────────────────────────────────
        ShadCard(
          padding: EdgeInsets.zero,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingRowColor: WidgetStateProperty.all(
                const Color(0xffFAFAFA),
              ),
              headingRowHeight: 38,
              dataRowMinHeight: 40,
              dataRowMaxHeight: 48,
              columnSpacing: 20,
              horizontalMargin: 16,
              columns: const [
                DataColumn(label: _ColHeader('Folio')),
                DataColumn(label: _ColHeader('Paciente')),
                DataColumn(label: _ColHeader('Fecha')),
                DataColumn(
                  label: _ColHeader('Total'),
                  numeric: true,
                ),
                DataColumn(
                  label: _ColHeader('A cuenta'),
                  numeric: true,
                ),
                DataColumn(
                  label: _ColHeader('Saldo'),
                  numeric: true,
                ),
              ],
              rows:
                  sales.map((sale) {
                    final rest = sale.rest ?? 0;
                    return DataRow(
                      cells: [
                        DataCell(
                          Text(
                            sale.folioSale ?? '—',
                            style: const TextStyle(
                              fontSize: 12,
                              fontFamily: 'monospace',
                              color: Color(0xff52525B),
                            ),
                          ),
                        ),
                        DataCell(
                          Text(
                            sale.patient ?? '—',
                            style: const TextStyle(
                              fontSize: 13,
                              color: Color(0xff18181B),
                            ),
                          ),
                        ),
                        DataCell(
                          Text(
                            _formatDate(sale.updatedDate ?? sale.date),
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xff52525B),
                            ),
                          ),
                        ),
                        DataCell(
                          Text(
                            (sale.totalWithDiscount ?? sale.total ?? 0)
                                .toCurrency(),
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Color(0xff18181B),
                            ),
                          ),
                        ),
                        DataCell(
                          Text(
                            (sale.account ?? 0).toCurrency(),
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xff52525B),
                            ),
                          ),
                        ),
                        DataCell(
                          Text(
                            rest.toCurrency(),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight:
                                  rest > 0
                                      ? FontWeight.w600
                                      : FontWeight.normal,
                              color:
                                  rest > 0
                                      ? const Color(0xffEF4444)
                                      : const Color(0xff71717A),
                            ),
                          ),
                        ),
                      ],
                    );
                  }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  String _formatDate(String? raw) {
    if (raw == null || raw.isEmpty) return '—';
    try {
      return DateFormat('dd/MM/yyyy').format(
        DateFormat('dd-MMM-yy', 'en_US').parse(raw),
      );
    } catch (_) {}
    try {
      return DateFormat('dd/MM/yyyy').format(DateTime.parse(raw));
    } catch (_) {}
    return raw;
  }
}

// ─── Summary card ─────────────────────────────────────────────────────────────

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.label,
    required this.value,
    required this.color,
    required this.bg,
    required this.icon,
  });

  final String label;
  final String value;
  final Color color;
  final Color bg;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: 160),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xffE4E4E7)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: 10,
        children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 16, color: color),
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
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Color(0xff18181B),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Helpers ──────────────────────────────────────────────────────────────────

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

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 64),
      child: Center(
        child: Column(
          spacing: 8,
          children: [
            Icon(Icons.inbox_outlined, size: 40, color: Colors.grey.shade300),
            Text(
              'Sin ventas en el período seleccionado',
              style: TextStyle(fontSize: 13, color: Colors.grey.shade400),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Commissions dialog ───────────────────────────────────────────────────────

class _CommissionsDialog extends StatefulWidget {
  const _CommissionsDialog({required this.sellerTotals});

  /// seller name → total sales amount
  final Map<String, double> sellerTotals;

  @override
  State<_CommissionsDialog> createState() => _CommissionsDialogState();
}

class _CommissionsDialogState extends State<_CommissionsDialog> {
  final _controller = TextEditingController();
  Map<String, double>? _commissions;
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _calculate() {
    final text = _controller.text.trim().replaceAll(',', '.');
    final pct = double.tryParse(text);
    if (pct == null || pct <= 0) {
      setState(() {
        _error = 'Ingresa un porcentaje válido mayor a 0';
        _commissions = null;
      });
      return;
    }
    setState(() {
      _error = null;
      _commissions = widget.sellerTotals.map(
        (seller, total) => MapEntry(seller, total * pct / 100),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 460),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 20,
            children: [
              // ── Title ─────────────────────────────────────────
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xffEEECFE),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.calculate_outlined,
                      size: 18,
                      color: Color(0xff7A6BF5),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: 2,
                      children: [
                        Text(
                          'Cálculo de comisiones',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Color(0xff18181B),
                          ),
                        ),
                        Text(
                          'Ingresa el porcentaje para calcular',
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xff71717A),
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close_rounded, size: 18),
                    style: IconButton.styleFrom(
                      side: const BorderSide(color: Color(0xffE4E4E7)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ],
              ),

              // ── Seller totals ──────────────────────────────────
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xffE4E4E7)),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  children: widget.sellerTotals.entries.map((e) {
                    final isLast =
                        e.key == widget.sellerTotals.keys.last;
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        border: isLast
                            ? null
                            : const Border(
                                bottom: BorderSide(
                                  color: Color(0xffF4F4F5),
                                ),
                              ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              e.key,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: Color(0xff18181B),
                              ),
                            ),
                          ),
                          Text(
                            e.value.toCurrency(),
                            style: const TextStyle(
                              fontSize: 13,
                              color: Color(0xff52525B),
                            ),
                          ),
                          if (_commissions != null) ...[
                            const SizedBox(width: 16),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xffDCFCE7),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                (_commissions![e.key] ?? 0).toCurrency(),
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xff16A34A),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),

              // ── Percentage input + button ──────────────────────
              Row(
                spacing: 10,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: 4,
                      children: [
                        TextField(
                          controller: _controller,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          decoration: InputDecoration(
                            hintText: 'Ej: 1.2',
                            suffixText: '%',
                            errorText: _error,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 10,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(
                                color: Color(0xffE4E4E7),
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(
                                color: Color(0xffE4E4E7),
                              ),
                            ),
                          ),
                          onSubmitted: (_) => _calculate(),
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    onPressed: _calculate,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xff7A6BF5),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Calcular',
                      style: TextStyle(fontWeight: FontWeight.w600),
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
