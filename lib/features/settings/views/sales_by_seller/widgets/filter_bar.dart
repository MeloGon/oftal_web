import 'package:flutter/material.dart';
import 'package:oftal_web/core/theme/app_colors.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

// ─── Filter bar ───────────────────────────────────────────────────────────────

class FilterBar extends StatelessWidget {
  const FilterBar({
    super.key,
    required this.selectedMonth,
    required this.onMonthPicked,
    required this.sellers,
    required this.sellerCounts,
    required this.isSellerActive,
    required this.onToggleSeller,
    required this.onSelectAll,
    required this.allActive,
  });

  final DateTime selectedMonth;
  final void Function(DateTime) onMonthPicked;
  final List<String> sellers;
  final Map<String, int> sellerCounts;
  final bool Function(String) isSellerActive;
  final void Function(String) onToggleSeller;
  final VoidCallback onSelectAll;
  final bool allActive;

  static const _months = [
    'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
    'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre',
  ];

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        // Month picker
        ShadButton.outline(
          onPressed: () async {
            final picked = await showDialog<DateTime>(
              context: context,
              builder: (_) => MonthPickerDialog(initial: selectedMonth),
            );
            if (picked != null) onMonthPicked(picked);
          },
          child: Row(
            spacing: 8,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.calendar_month_rounded, size: 14),
              Text('${_months[selectedMonth.month - 1]} ${selectedMonth.year}'),
            ],
          ),
        ),

        if (sellers.isNotEmpty) ...[
          Container(width: 1, height: 20, color: AppColors.zinc200),

          const Text(
            'Vendedores:',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppColors.zinc500,
            ),
          ),

          // Todos chip
          SellerChip(
            label: 'Todos',
            selected: allActive,
            onTap: onSelectAll,
          ),

          // Individual seller chips
          ...sellers.map((s) => SellerChip(
                label: s,
                count: sellerCounts[s],
                selected: isSellerActive(s),
                onTap: () => onToggleSeller(s),
              )),
        ],
      ],
    );
  }
}

// ─── Seller chip ──────────────────────────────────────────────────────────────

class SellerChip extends StatelessWidget {
  const SellerChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
    this.count,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final int? count;

  @override
  Widget build(BuildContext context) {
    final chipLabel = count != null ? '$label \u00b7 $count' : label;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : AppColors.zinc50,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.zinc200,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          spacing: 5,
          children: [
            if (selected)
              const Icon(
                Icons.check_rounded,
                size: 12,
                color: Colors.white,
              ),
            Text(
              chipLabel,
              style: TextStyle(
                fontSize: 12,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                color: selected ? Colors.white : AppColors.zinc600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Month picker dialog ──────────────────────────────────────────────────────

class MonthPickerDialog extends StatefulWidget {
  const MonthPickerDialog({super.key, required this.initial});
  final DateTime initial;

  @override
  State<MonthPickerDialog> createState() => MonthPickerDialogState();
}

class MonthPickerDialogState extends State<MonthPickerDialog> {
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
                    side: const BorderSide(color: AppColors.zinc200),
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
                    color: AppColors.zinc900,
                  ),
                ),
                IconButton(
                  onPressed: _year < _maxYear
                      ? () => setState(() => _year++)
                      : null,
                  icon: const Icon(Icons.chevron_right_rounded),
                  style: IconButton.styleFrom(
                    side: const BorderSide(color: AppColors.zinc200),
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
                          ? AppColors.primary
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.zinc200,
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
                              ? AppColors.zinc300
                              : isSelected
                                  ? Colors.white
                                  : AppColors.zinc900,
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
