import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:oftal_web/features/dashboard/viewmodels/dashboard_provider.dart';
import 'package:oftal_web/features/dashboard/views/widgets/audit_log_card.dart';
import 'package:oftal_web/features/dashboard/views/widgets/expenses_donut_chart.dart';
import 'package:oftal_web/features/dashboard/views/widgets/greeting_banner.dart';
import 'package:oftal_web/features/dashboard/views/widgets/payment_donut.dart';
import 'package:oftal_web/features/dashboard/views/widgets/quick_actions.dart';
import 'package:oftal_web/features/dashboard/views/widgets/recent_sales_list.dart';
import 'package:oftal_web/features/dashboard/views/widgets/sales_bar_chart.dart';
import 'package:oftal_web/features/dashboard/views/widgets/stats_row.dart';

class DashboardView extends ConsumerWidget {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(dashboardProviderProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 20,
        children: [
          GreetingBanner(state: s),
          StatsRow(state: s),
          LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth < 650) {
                return Column(
                  spacing: 16,
                  children: [
                    SalesBarChart(state: s),
                    PaymentDonut(state: s),
                  ],
                );
              }
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 16,
                children: [
                  Expanded(flex: 5, child: SalesBarChart(state: s)),
                  Expanded(flex: 3, child: PaymentDonut(state: s)),
                ],
              );
            },
          ),
          LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth < 650) {
                return Column(
                  spacing: 16,
                  children: [
                    RecentSalesList(state: s),
                    QuickActions(ref: ref),
                  ],
                );
              }
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 16,
                children: [
                  Expanded(flex: 5, child: RecentSalesList(state: s)),
                  Expanded(flex: 3, child: QuickActions(ref: ref)),
                ],
              );
            },
          ),
          const ExpensesDonutChart(),
          LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth < 650) {
                return const AuditLogCard();
              }
              return const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 5, child: AuditLogCard()),
                  Expanded(flex: 3, child: SizedBox()),
                ],
              );
            },
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
