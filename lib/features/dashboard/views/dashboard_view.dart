import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:oftal_web/features/dashboard/viewmodels/dashboard_provider.dart';
import 'package:oftal_web/features/dashboard/views/widgets/card_statistic_item.dart';
// import 'package:oftal_web/shared/providers/providers.dart';

class DashboardView extends ConsumerWidget {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardState = ref.watch(dashboardProviderProvider);
    // final dashboardNotifier = ref.read(dashboardProviderProvider.notifier);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
        children: [
          Wrap(
            children: [
              CardStatisticItem(
                title: 'Ventas del día',
                content: '${dashboardState.salesToday}',
              ),
              CardStatisticItem(
                title: 'Clientes de la sucursal',
                content: '${dashboardState.clientsByBranch}',
              ),
            ],
          ),
          SizedBox(
            height: 300,
            width: MediaQuery.sizeOf(context).width * .9,
            child: LineChart(
              LineChartData(
                // lineBarsData: [
                //   LineChartBarData(
                //     spots: [
                //       FlSpot(0, 0),
                //       FlSpot(1, 1),
                //       FlSpot(2, 2),
                //     ],
                //   ),
                // ],
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: true,
                  drawHorizontalLine: true,
                ),
                titlesData: FlTitlesData(
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
