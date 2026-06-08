import 'package:flutter/material.dart';
import 'package:oftal_web/core/theme/app_colors.dart';
import 'package:oftal_web/features/dashboard/viewmodels/dashboard_state.dart';
import 'package:oftal_web/shared/extensions/extensions.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class StatsRow extends StatelessWidget {
  const StatsRow({super.key, required this.state});
  final DashboardState state;

  @override
  Widget build(BuildContext context) {
    final card1 = StatCard(
      label: 'Mis ventas hoy',
      value: '${state.salesToday}',
      icon: Icons.receipt_long_outlined,
      iconColor: AppColors.primary,
      iconBg: AppColors.primaryBg,
    );
    final card2 = StatCard(
      label: 'Ingresos hoy',
      value: state.incomeToday > 0 ? state.incomeToday.toCurrency() : '—',
      icon: Icons.payments_outlined,
      iconColor: AppColors.successDark,
      iconBg: AppColors.successBg,
    );
    final card3 = StatCard(
      label: 'Clientes en sucursal',
      value: '${state.clientsByBranch}',
      icon: Icons.people_outline_rounded,
      iconColor: AppColors.sky,
      iconBg: AppColors.skyBg,
    );
    final card4 = StatCard(
      label: 'Sucursal',
      value: state.branchName.isEmpty ? '—' : state.branchName,
      icon: Icons.store_outlined,
      iconColor: AppColors.emerald,
      iconBg: AppColors.emeraldBg,
      smallValue: true,
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 560) {
          return Column(
            spacing: 12,
            children: [
              Row(
                spacing: 16,
                children: [Expanded(child: card1), Expanded(child: card2)],
              ),
              Row(
                spacing: 16,
                children: [Expanded(child: card3), Expanded(child: card4)],
              ),
            ],
          );
        }
        return Row(
          spacing: 16,
          children: [
            Expanded(child: card1),
            Expanded(child: card2),
            Expanded(child: card3),
            Expanded(child: card4),
          ],
        );
      },
    );
  }
}

class StatCard extends StatelessWidget {
  const StatCard({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    this.smallValue = false,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final bool smallValue;

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
            children: [
              Expanded(
                child: Text(
                  label,
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
            style: TextStyle(
              fontSize: smallValue ? 18 : 26,
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
