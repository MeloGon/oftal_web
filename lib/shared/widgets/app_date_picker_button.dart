import 'package:flutter/material.dart';
import 'package:oftal_web/core/theme/app_colors.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class AppDatePickerButton extends StatelessWidget {
  const AppDatePickerButton({
    super.key,
    required this.selectedDate,
    required this.onDateSelected,
    this.label,
    this.firstDate,
    this.lastDate,
  });

  final DateTime selectedDate;
  final ValueChanged<DateTime> onDateSelected;
  final String? label;
  final DateTime? firstDate;
  final DateTime? lastDate;

  static final _fmt = DateFormat("d 'de' MMMM 'de' yyyy", 'es_MX');

  Future<void> _pick(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: firstDate ?? DateTime(1900),
      lastDate: lastDate ?? DateTime(2100),
      locale: const Locale('es', 'MX'),
    );
    if (picked != null) {
      // Normalize to pure local date (year/month/day only) to avoid
      // any timezone drift when showDatePicker returns UTC midnight.
      onDateSelected(DateTime(picked.year, picked.month, picked.day));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (label != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Text(
              label!,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppColors.zinc600,
              ),
            ),
          ),
        ShadButton.outline(
          onPressed: () => _pick(context),
          leading: const Icon(Icons.calendar_today_outlined, size: 14),
          child: Text(_fmt.format(selectedDate)),
        ),
      ],
    );
  }
}
