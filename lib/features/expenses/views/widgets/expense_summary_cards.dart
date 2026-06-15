import 'package:flutter/material.dart';
import 'package:oftal_web/core/theme/app_colors.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class ExpenseSummaryCards extends StatelessWidget {
  const ExpenseSummaryCards({
    super.key,
    required this.totalAmount,
    required this.recordCount,
    required this.categoryCount,
  });

  final String totalAmount;
  final String recordCount;
  final String categoryCount;

  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: 12,
      children: [
        Expanded(
          child: _SummaryCard(
            label: 'Total egresos',
            value: totalAmount,
            icon: Icons.account_balance_wallet_outlined,
            iconColor: AppColors.error,
            iconBg: AppColors.errorBg,
          ),
        ),
        Expanded(
          child: _SummaryCard(
            label: 'Registros',
            value: recordCount,
            icon: Icons.receipt_long_outlined,
            iconColor: AppColors.indigo,
            iconBg: AppColors.primaryBg,
          ),
        ),
        Expanded(
          child: _SummaryCard(
            label: 'Categorías',
            value: categoryCount,
            icon: Icons.label_outline,
            iconColor: AppColors.emerald,
            iconBg: AppColors.emeraldBg,
          ),
        ),
      ],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.iconColor,
    required this.iconBg,
  });
  final String label;
  final String value;
  final IconData icon;
  final Color iconColor;
  final Color iconBg;

  @override
  Widget build(BuildContext context) {
    return ShadCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 12,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            spacing: 12,
            children: [
              Expanded(
                child: Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.shade600,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 16, color: iconColor),
              ),
            ],
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: AppColors.zinc900,
              height: 1,
            ),
          ),
        ],
      ),
    );
  }
}
