import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:oftal_web/core/theme/app_colors.dart';
import 'package:oftal_web/features/sales_history/viewmodels/sales_history_provider.dart';
import 'package:oftal_web/features/sales_history/views/widgets/register_payment_dialog.dart';
import 'package:oftal_web/features/sales_history/views/widgets/sales_history_actions.dart';
import 'package:oftal_web/shared/extensions/extensions.dart';
import 'package:oftal_web/shared/models/shared_models.dart';
import 'package:oftal_web/shared/widgets/field_chip.dart';

class SaleHistoryTile extends ConsumerWidget {
  const SaleHistoryTile({
    super.key,
    required this.sale,
    required this.changeDateEnabled,
  });
  final SalesModel sale;
  final bool changeDateEnabled;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(salesHistoryProvider.notifier);
    final isPaid = (sale.rest ?? 0) == 0;
    final hasDiscount = (sale.discount ?? 0) > 0;

    return InkWell(
      onDoubleTap: () => notifier.selectSaleForDetails(sale),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Row(
          spacing: 14,
          children: [
            // ─ Ícono estado ────────────────────────────────
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: isPaid ? AppColors.successBg : AppColors.warningBg,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                isPaid
                    ? Icons.check_circle_outline_rounded
                    : Icons.schedule_rounded,
                size: 16,
                color: isPaid ? AppColors.successDark : AppColors.warningDark,
              ),
            ),

            // ─ Info ────────────────────────────────────────
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 3,
                children: [
                  Row(
                    spacing: 8,
                    children: [
                      Text(
                        '#${sale.folioSale ?? '—'}',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.zinc500,
                        ),
                      ),
                      Flexible(
                        child: Text(
                          sale.patient ?? '—',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.zinc900,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      _StatusBadge(isPaid: isPaid),
                    ],
                  ),
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: [
                      FieldChip(label: 'Fecha', value: sale.date ?? '—'),
                      FieldChip(
                        label: 'Vendedor',
                        value: sale.authorName ?? '—',
                      ),
                      FieldChip(label: 'Sucursal', value: sale.branch ?? '—'),
                      FieldChip(
                        label: 'A cuenta',
                        value: (sale.account ?? 0).toCurrency(),
                      ),
                      if (hasDiscount) ...[
                        FieldChip(
                          label: 'Total',
                          value: (sale.total ?? 0).toCurrency(),
                        ),
                        FieldChip(
                          label: 'Descuento',
                          value: sale.discount!.toCurrency(),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),

            // ─ Montos ──────────────────────────────────────
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              spacing: 2,
              children: [
                Text(
                  (sale.totalWithDiscount ?? sale.total ?? 0).toCurrency(),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.zinc900,
                  ),
                ),
                if (!isPaid)
                  Text(
                    'Resta ${sale.rest!.toCurrency()}',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.error,
                    ),
                  ),
              ],
            ),

            // ─ Actions ─────────────────────────────────────
            SalesHistoryActions(
              sale: sale,
              changeDateEnabled: changeDateEnabled,
              onViewDetails: () => notifier.selectSaleForDetails(sale),
              onPrintSale: () async {
                notifier.selectSaleForDetails(sale);
                await notifier.getSalesDetails();
                await notifier.generatePdf(sale);
              },
              onDeleteSale: () => notifier.deleteSale(sale),
              onFinalizeSale: () => notifier.finalizeSale(sale),
              onRegisterPayment: () =>
                  RegisterPaymentDialog().show(context, ref, sale),
              onChangeDate: (date) => notifier.updateSaleDate(sale, date),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.isPaid});
  final bool isPaid;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: isPaid ? AppColors.successBg : AppColors.warningBg,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        isPaid ? 'Pagada' : 'Pendiente',
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: isPaid ? AppColors.successDark : AppColors.warningDark,
        ),
      ),
    );
  }
}
