import 'dart:math' show max;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:oftal_web/core/theme/app_colors.dart';
import 'package:oftal_web/features/dashboard/viewmodels/dashboard_state.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

const kDayLabels = ['L', 'M', 'X', 'J', 'V', 'S', 'D'];

class SalesBarChart extends StatelessWidget {
  const SalesBarChart({super.key, required this.state});
  final DashboardState state;

  @override
  Widget build(BuildContext context) {
    final data = state.salesByDay;
    final isEmpty = data.isEmpty;

    return ShadCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 16,
        children: [
          const Text(
            'Ventas últimos 7 días',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.zinc900,
            ),
          ),
          SizedBox(
            height: 220,
            child: isEmpty
                ? const Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.primary,
                    ),
                  )
                : _buildChart(data),
          ),
        ],
      ),
    );
  }

  Widget _buildChart(Map<String, int> data) {
    final entries = data.entries.toList();
    final maxVal =
        entries.map((e) => e.value).fold(0, (a, b) => max(a, b)).toDouble();
    final maxY = max(maxVal + 1, 3.0);

    return BarChart(
      BarChartData(
        maxY: maxY,
        barGroups: entries.asMap().entries.map((e) {
          return BarChartGroupData(
            x: e.key,
            barRods: [
              BarChartRodData(
                toY: e.value.value.toDouble(),
                color: AppColors.primary,
                width: 22,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(5),
                ),
                backDrawRodData: BackgroundBarChartRodData(
                  show: true,
                  toY: maxY,
                  color: AppColors.zinc100,
                ),
              ),
            ],
          );
        }).toList(),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 28,
              getTitlesWidget: (value, meta) {
                final idx = value.toInt();
                if (idx < 0 || idx >= entries.length) {
                  return const SizedBox.shrink();
                }
                final dt = DateTime.tryParse(entries[idx].key);
                final label =
                    dt != null ? kDayLabels[dt.weekday - 1] : '';
                return Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    label,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.zinc500,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              interval: maxY > 10 ? (maxY / 5).roundToDouble() : 1,
              getTitlesWidget: (value, meta) {
                if (value != value.roundToDouble()) {
                  return const SizedBox.shrink();
                }
                return Text(
                  value.toInt().toString(),
                  style: const TextStyle(
                    fontSize: 10,
                    color: AppColors.zinc500,
                  ),
                );
              },
            ),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: maxY > 10 ? (maxY / 5).roundToDouble() : 1,
          getDrawingHorizontalLine: (_) =>
              const FlLine(color: AppColors.zinc100, strokeWidth: 1),
        ),
        borderData: FlBorderData(show: false),
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            getTooltipColor: (_) => AppColors.zinc900,
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              return BarTooltipItem(
                rod.toY.toInt().toString(),
                const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
