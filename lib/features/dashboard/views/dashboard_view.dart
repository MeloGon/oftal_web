import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:oftal_web/features/dashboard/viewmodels/dashboard_provider.dart';
import 'package:oftal_web/features/dashboard/views/widgets/card_statistic_item.dart';

class DashboardView extends ConsumerWidget {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardState = ref.watch(dashboardProviderProvider);

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 24,
        children: [
          // ─── Page header ─────────────────────────────────
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 4,
            children: [
              const Text(
                'Panel principal',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: Color(0xff18181B),
                ),
              ),
              Text(
                'Resumen de actividad de la sucursal',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade500,
                ),
              ),
            ],
          ),

          // ─── Stats cards ─────────────────────────────────
          Row(
            spacing: 16,
            children: [
              Expanded(
                child: CardStatisticItem(
                  title: 'Ventas del día',
                  content: '${dashboardState.salesToday}',
                  icon: Icons.receipt_long_outlined,
                  iconColor: const Color(0xff7A6BF5),
                  iconBgColor: const Color(0xffEEECFE),
                ),
              ),
              Expanded(
                child: CardStatisticItem(
                  title: 'Clientes de la sucursal',
                  content: '${dashboardState.clientsByBranch}',
                  icon: Icons.people_outline_rounded,
                  iconColor: const Color(0xff0EA5E9),
                  iconBgColor: const Color(0xffE0F2FE),
                ),
              ),
              Expanded(
                child: CardStatisticItem(
                  title: 'Sucursal de trabajo',
                  content: dashboardState.branchName,
                  icon: Icons.store_outlined,
                  iconColor: const Color(0xff10B981),
                  iconBgColor: const Color(0xffD1FAE5),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
