import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:oftal_web/core/theme/app_colors.dart';
import 'package:oftal_web/features/dashboard/viewmodels/dashboard_state.dart';
import 'package:oftal_web/router/app_router.dart';
import 'package:oftal_web/router/router_name.dart';
import 'package:oftal_web/shared/extensions/extensions.dart';
import 'package:oftal_web/shared/models/shared_models.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class RecentSalesList extends ConsumerWidget {
  const RecentSalesList({super.key, required this.state});
  final DashboardState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ShadCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 14,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Últimas ventas',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.zinc900,
                ),
              ),
              GestureDetector(
                onTap: () =>
                    ref.read(appRouterProvider).go(RouterName.salesHistory),
                child: const Text(
                  'Ver todas →',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          if (state.recentSales.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Center(
                child: Text(
                  'Sin ventas recientes',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade400),
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: state.recentSales.length,
              separatorBuilder: (_, _) =>
                  const Divider(height: 1, color: AppColors.zinc100),
              itemBuilder: (context, i) =>
                  SaleRow(sale: state.recentSales[i]),
            ),
        ],
      ),
    );
  }
}

class SaleRow extends StatelessWidget {
  const SaleRow({super.key, required this.sale});
  final SalesModel sale;

  @override
  Widget build(BuildContext context) {
    final isPaid = (sale.rest ?? 0) == 0;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: isPaid
                  ? AppColors.successDark
                  : AppColors.warningDark,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              sale.patient ?? '—',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppColors.zinc900,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            sale.date ?? '',
            style: const TextStyle(fontSize: 11, color: AppColors.zinc500),
          ),
          const SizedBox(width: 12),
          Text(
            (sale.totalWithDiscount ?? sale.total)?.toCurrency() ?? '—',
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.zinc900,
            ),
          ),
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: isPaid
                  ? AppColors.successBg
                  : AppColors.warningBg,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              isPaid ? 'C' : 'P',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: isPaid
                    ? AppColors.successDark
                    : AppColors.warningDark,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
