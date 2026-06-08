import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:oftal_web/core/theme/app_colors.dart';
import 'package:oftal_web/features/dashboard/viewmodels/dashboard_state.dart';
import 'package:oftal_web/shared/extensions/extensions.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

Color methodColor(String method) {
  switch (method.toLowerCase()) {
    case 'efectivo':
      return AppColors.successDark;
    case 'tarjeta':
      return AppColors.sky;
    case 'transferencia':
      return AppColors.primary;
    case 'nomina':
      return AppColors.warningDark;
    default:
      return AppColors.zinc500;
  }
}

String _capitalize(String s) =>
    s.isEmpty ? s : '${s[0].toUpperCase()}${s.substring(1)}';

class PaymentDonut extends StatelessWidget {
  const PaymentDonut({super.key, required this.state});
  final DashboardState state;

  @override
  Widget build(BuildContext context) {
    final methods = state.paymentsByMethod;

    return ShadCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 16,
        children: [
          const Text(
            'Métodos de pago hoy',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.zinc900,
            ),
          ),
          SizedBox(
            height: 220,
            child: methods.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      spacing: 8,
                      children: [
                        Icon(
                          Icons.payments_outlined,
                          size: 32,
                          color: Colors.grey.shade300,
                        ),
                        Text(
                          'Sin pagos hoy',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade400,
                          ),
                        ),
                      ],
                    ),
                  )
                : Row(
                    children: [
                      Expanded(
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            PieChart(
                              PieChartData(
                                sections: methods.entries.map((e) {
                                  return PieChartSectionData(
                                    value: e.value,
                                    color: methodColor(e.key),
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
                                  state.incomeToday.toCurrency(),
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
                        children: methods.entries.map((e) {
                          final pct =
                              (e.value / state.incomeToday * 100)
                                  .toStringAsFixed(0);
                          return Row(
                            spacing: 6,
                            children: [
                              Container(
                                width: 10,
                                height: 10,
                                decoration: BoxDecoration(
                                  color: methodColor(e.key),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _capitalize(e.key),
                                    style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w500,
                                      color: AppColors.zinc900,
                                    ),
                                  ),
                                  Text(
                                    '$pct%',
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
          ),
        ],
      ),
    );
  }
}
