import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:oftal_web/core/theme/app_colors.dart';
import 'package:oftal_web/features/expenses/viewmodels/expenses_provider.dart';
import 'package:oftal_web/router/app_router.dart';
import 'package:oftal_web/router/router_name.dart';
import 'package:oftal_web/shared/extensions/extensions.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

const kExpenseColors = [
  AppColors.indigo,
  AppColors.error,
  AppColors.warning,
  AppColors.emerald,
  AppColors.sky,
  AppColors.transferencia,
  AppColors.pink,
  AppColors.teal,
];

class ExpensesDonutChart extends ConsumerWidget {
  const ExpensesDonutChart({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summary = ref.watch(expensesSummaryProvider);

    return ShadCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 16,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Egresos del mes por categoría',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.zinc900,
                ),
              ),
              GestureDetector(
                onTap: () =>
                    ref.read(appRouterProvider).go(RouterName.expenses),
                child: const Text(
                  'Ver todos →',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          summary.when(
            loading: () => const SizedBox(
              height: 180,
              child: Center(
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.primary,
                ),
              ),
            ),
            error: (_, __) => const SizedBox(
              height: 100,
              child: Center(
                child: Text(
                  'Error al cargar egresos',
                  style: TextStyle(fontSize: 12, color: AppColors.zinc500),
                ),
              ),
            ),
            data: (data) {
              if (data.isEmpty) {
                return SizedBox(
                  height: 100,
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      spacing: 8,
                      children: [
                        Icon(
                          Icons.account_balance_wallet_outlined,
                          size: 32,
                          color: Colors.grey.shade300,
                        ),
                        Text(
                          'Sin egresos este mes',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade400,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              final entries = data.entries.toList();
              final total = entries.fold(0.0, (s, e) => s + e.value);

              return SizedBox(
                height: 180,
                child: Row(
                  children: [
                    Expanded(
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          PieChart(
                            PieChartData(
                              sections: entries.asMap().entries.map((e) {
                                final color =
                                    kExpenseColors[e.key % kExpenseColors.length];
                                return PieChartSectionData(
                                  value: e.value.value,
                                  color: color,
                                  title: '',
                                  radius: 46,
                                );
                              }).toList(),
                              centerSpaceRadius: 52,
                              sectionsSpace: 2,
                            ),
                          ),
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                total.toCurrency(),
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.zinc900,
                                ),
                              ),
                              Text(
                                'total',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.grey.shade500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: 8,
                      children: entries.asMap().entries.map((e) {
                        final color =
                            kExpenseColors[e.key % kExpenseColors.length];
                        final pct =
                            (e.value.value / total * 100).toStringAsFixed(0);
                        return Row(
                          spacing: 6,
                          children: [
                            Container(
                              width: 10,
                              height: 10,
                              decoration: BoxDecoration(
                                color: color,
                                shape: BoxShape.circle,
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  e.value.key,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.zinc900,
                                  ),
                                ),
                                Text(
                                  '$pct% · ${e.value.value.toCurrency()}',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.grey.shade500,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
