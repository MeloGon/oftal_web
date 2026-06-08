import 'package:flutter/material.dart';
import 'package:oftal_web/core/theme/app_colors.dart';
import 'package:oftal_web/shared/extensions/extensions.dart';

class PaymentsSummaryRow extends StatelessWidget {
  const PaymentsSummaryRow({
    super.key,
    required this.total,
    required this.byMethod,
  });

  final double total;
  final Map<String, double> byMethod;

  static const _methodMeta = <String, MethodMeta>{
    'efectivo': MethodMeta(
      label: 'Efectivo',
      icon: Icons.payments_outlined,
      color: AppColors.efectivo,
      bg: AppColors.successBg,
    ),
    'tarjeta': MethodMeta(
      label: 'Tarjeta',
      icon: Icons.credit_card_rounded,
      color: AppColors.tarjeta,
      bg: AppColors.blueBgDark,
    ),
    'transferencia': MethodMeta(
      label: 'Transferencia',
      icon: Icons.swap_horiz_rounded,
      color: AppColors.transferencia,
      bg: AppColors.violetBg,
    ),
    'nomina': MethodMeta(
      label: 'Nómina',
      icon: Icons.account_balance_outlined,
      color: AppColors.warning,
      bg: AppColors.warningBgLight,
    ),
    'otro': MethodMeta(
      label: 'Otro',
      icon: Icons.more_horiz_rounded,
      color: AppColors.gray500,
      bg: AppColors.gray100,
    ),
  };

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        MetricCard(
          label: 'Total ingresado',
          value: total.toCurrency(),
          icon: Icons.trending_up_rounded,
          iconColor: AppColors.sky,
          iconBg: AppColors.skyBg,
          isTotal: true,
        ),
        ...byMethod.entries.map((entry) {
          final meta = _methodMeta[entry.key] ?? _methodMeta['otro']!;
          return MetricCard(
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

class MethodMeta {
  const MethodMeta({
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

class MetricCard extends StatelessWidget {
  const MetricCard({
    super.key,
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
          color:
              isTotal
                  ? iconColor.withValues(alpha: 0.3)
                  : AppColors.zinc200,
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
                  color: isTotal ? iconColor : AppColors.zinc900,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
