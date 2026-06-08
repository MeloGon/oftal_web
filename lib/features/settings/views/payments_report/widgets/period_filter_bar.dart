import 'package:flutter/material.dart';
import 'package:oftal_web/core/enums/enums.dart';
import 'package:oftal_web/core/theme/app_colors.dart';
import 'package:oftal_web/features/settings/viewmodels/payments_report_provider.dart';
import 'package:oftal_web/features/settings/viewmodels/payments_report_state.dart';
import 'package:oftal_web/features/settings/views/payments_report/widgets/sucursal_filter.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class PeriodFilterBar extends StatelessWidget {
  const PeriodFilterBar({
    super.key,
    required this.state,
    required this.notifier,
    required this.availableSucursales,
  });

  final PaymentsReportState state;
  final PaymentsReport notifier;
  final List<String> availableSucursales;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 16,
      runSpacing: 10,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        // Segmented tabs
        Container(
          decoration: BoxDecoration(
            color: AppColors.zinc100,
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.all(3),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children:
                ReportPeriodFilter.values.map((f) {
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
                        boxShadow:
                            selected
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
                          fontWeight:
                              selected ? FontWeight.w600 : FontWeight.w400,
                          color:
                              selected
                                  ? AppColors.zinc900
                                  : AppColors.zinc500,
                        ),
                      ),
                    ),
                  );
                }).toList(),
          ),
        ),

        // Date controls depending on mode
        DateControls(state: state, notifier: notifier),

        // Sucursal filter
        if (availableSucursales.isNotEmpty)
          SucursalFilter(
            sucursales: availableSucursales,
            selected: state.selectedSucursal,
            onChanged: notifier.selectSucursal,
          ),
      ],
    );
  }
}

class DateControls extends StatelessWidget {
  const DateControls({super.key, required this.state, required this.notifier});

  final PaymentsReportState state;
  final PaymentsReport notifier;

  @override
  Widget build(BuildContext context) {
    return switch (state.filter) {
      ReportPeriodFilter.day => DayPicker(
        selected: state.selectedDay,
        onPicked: notifier.selectDay,
      ),
      ReportPeriodFilter.month => MonthPicker(
        selected: state.selectedMonth,
        onPicked: notifier.selectMonth,
      ),
      ReportPeriodFilter.range => RangePicker(
        start: state.rangeStart,
        end: state.rangeEnd,
        onStartPicked: notifier.selectRangeStart,
        onEndPicked: notifier.selectRangeEnd,
      ),
    };
  }
}

// --- Day picker ---------------------------------------------------------------

class DayPicker extends StatelessWidget {
  const DayPicker({super.key, required this.selected, required this.onPicked});

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

// --- Month picker -------------------------------------------------------------

class MonthPicker extends StatelessWidget {
  const MonthPicker({super.key, required this.selected, required this.onPicked});

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

// --- Range picker -------------------------------------------------------------

class RangePicker extends StatelessWidget {
  const RangePicker({
    super.key,
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
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      crossAxisAlignment: WrapCrossAlignment.center,
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
        const Icon(
          Icons.arrow_forward_rounded,
          size: 14,
          color: AppColors.zinc500,
        ),
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
