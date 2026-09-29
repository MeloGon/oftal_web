import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:oftal_web/core/theme/app_colors.dart';
import 'package:oftal_web/features/sales_history/viewmodels/sales_history_provider.dart';
import 'package:oftal_web/features/sales_history/views/widgets/register_payment_dialog.dart';
import 'package:oftal_web/features/sales_history/views/widgets/sales_history_actions.dart';
import 'package:oftal_web/shared/extensions/extensions.dart';
import 'package:oftal_web/shared/models/shared_models.dart';

/// Highly optimized sale history tile for Flutter Web:
/// - Uses [RepaintBoundary] to isolate paint and hover states.
/// - Uses lightweight [FractionallySizedBox] instead of Material [LinearProgressIndicator]
///   to avoid unnecessary AnimationControllers and Theme lookups.
/// - Web mouse cursor & hover states.
/// - Quick click-to-copy for Folio.
class SaleHistoryTile extends ConsumerWidget {
  const SaleHistoryTile({
    super.key,
    required this.sale,
    required this.changeDateEnabled,
    this.showProgressBar = true,
  });

  final SalesModel sale;
  final bool changeDateEnabled;
  final bool showProgressBar;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(salesHistoryProvider.notifier);
    final isPaid = (sale.rest ?? 0) == 0;
    final hasDiscount = (sale.discount ?? 0) > 0;
    final total = sale.totalWithDiscount ?? sale.total ?? 0.0;
    final account = sale.account ?? 0.0;
    final rest = sale.rest ?? 0.0;

    return RepaintBoundary(
      child: Material(
        color: isPaid
            ? Colors.transparent
            : AppColors.warningBg.withValues(alpha: 0.12),
        child: InkWell(
          hoverColor: AppColors.zinc100.withValues(alpha: 0.6),
          onDoubleTap: () => notifier.selectSaleForDetails(sale),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Row(
              spacing: 14,
              children: [
                // ─ 1. Ícono de estado ──────────────────────────────
                _StatusIcon(isPaid: isPaid),

                // ─ 2. Info Central (Eyebrow + Paciente + Metadatos) ─
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 4,
                    children: [
                      // Eyebrow: Folio (Copiable al clic) + Sucursal + Estado
                      Row(
                        spacing: 6,
                        children: [
                          _FolioChip(folio: sale.folioSale),
                          const Text(
                            '•',
                            style: TextStyle(
                              fontSize: 11,
                              color: AppColors.zinc300,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          _BranchBadge(branch: sale.branch ?? '—'),
                          const Text(
                            '•',
                            style: TextStyle(
                              fontSize: 11,
                              color: AppColors.zinc300,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          _StatusBadge(isPaid: isPaid),
                        ],
                      ),

                      // Paciente (nombre amplio y destacado con ellipsis seguro)
                      Text(
                        sale.patient ?? '—',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.zinc900,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),

                      // Metadatos: Fecha • Vendedor • Descuento • (Fallback de saldos si compacto)
                      Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            spacing: 4,
                            children: [
                              const Icon(
                                Icons.calendar_today_outlined,
                                size: 12,
                                color: AppColors.zinc400,
                              ),
                              Text(
                                sale.date ?? '—',
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: AppColors.zinc600,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          const Text(
                            '•',
                            style: TextStyle(
                              color: AppColors.zinc300,
                              fontSize: 11,
                            ),
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            spacing: 4,
                            children: [
                              const Icon(
                                Icons.person_outline_rounded,
                                size: 13,
                                color: AppColors.zinc400,
                              ),
                              Text(
                                'Vend: ${sale.authorName ?? '—'}',
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: AppColors.zinc600,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          if (hasDiscount) ...[
                            const Text(
                              '•',
                              style: TextStyle(
                                color: AppColors.zinc300,
                                fontSize: 11,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 1,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.violetBgLight,
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(
                                  color: AppColors.indigoBorder.withValues(
                                    alpha: 0.5,
                                  ),
                                ),
                              ),
                              child: Text(
                                'Desc: -${sale.discount!.toCurrency()}',
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.indigo,
                                ),
                              ),
                            ),
                          ],
                          if (!showProgressBar) ...[
                            const Text(
                              '•',
                              style: TextStyle(
                                color: AppColors.zinc300,
                                fontSize: 11,
                              ),
                            ),
                            Text(
                              isPaid
                                  ? 'Abonado: ${account.toCurrency()}'
                                  : 'Abonó: ${account.toCurrency()} (Debe: ${rest.toCurrency()})',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: isPaid
                                    ? AppColors.successDark
                                    : AppColors.error,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),

                // ─ 3. Barra Visual de Avance de Pago (Ultra ligera para Web) ──
                if (showProgressBar)
                  _PaymentProgressBar(
                    isPaid: isPaid,
                    total: total,
                    account: account,
                    rest: rest,
                  ),

                // ─ 4. Monto Total y Botón Directo ─────────────────
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.center,
                  spacing: 4,
                  children: [
                    Text(
                      total.toCurrency(),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: AppColors.zinc900,
                        letterSpacing: -0.2,
                      ),
                    ),
                    if (!isPaid)
                      InkWell(
                        onTap: () =>
                            RegisterPaymentDialog().show(context, ref, sale),
                        borderRadius: BorderRadius.circular(6),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.warningBg,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: AppColors.warningDark.withValues(
                                alpha: 0.3,
                              ),
                            ),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            spacing: 3,
                            children: [
                              Icon(
                                Icons.add_rounded,
                                size: 13,
                                color: AppColors.warningDark,
                              ),
                              Text(
                                'Abonar',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.warningDark,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.successBg,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'Liquidada',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: AppColors.successDark,
                          ),
                        ),
                      ),
                  ],
                ),

                // ─ 5. Acciones secundarias (3 puntos) ───────────────
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
        ),
      ),
    );
  }
}

/// Status icon with const decoration
class _StatusIcon extends StatelessWidget {
  const _StatusIcon({required this.isPaid});
  final bool isPaid;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        color: isPaid ? AppColors.successBg : AppColors.warningBg,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(
        isPaid
            ? Icons.check_circle_outline_rounded
            : Icons.schedule_rounded,
        size: 18,
        color: isPaid ? AppColors.successDark : AppColors.warningDark,
      ),
    );
  }
}

/// Folio chip with one-click copy support for web users
class _FolioChip extends StatelessWidget {
  const _FolioChip({required this.folio});
  final String? folio;

  @override
  Widget build(BuildContext context) {
    final text = '#${folio ?? '—'}';
    return Tooltip(
      message: 'Clic para copiar folio',
      waitDuration: const Duration(milliseconds: 500),
      child: InkWell(
        onTap: () {
          if (folio != null && folio!.isNotEmpty) {
            Clipboard.setData(ClipboardData(text: folio!));
            ScaffoldMessenger.of(context).clearSnackBars();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Folio $folio copiado al portapapeles'),
                duration: const Duration(seconds: 1),
                behavior: SnackBarBehavior.floating,
                width: 280,
              ),
            );
          }
        },
        borderRadius: BorderRadius.circular(4),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 1),
          child: Text(
            text,
            style: const TextStyle(
              fontFamily: 'monospace',
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppColors.zinc500,
            ),
          ),
        ),
      ),
    );
  }
}

class _BranchBadge extends StatelessWidget {
  const _BranchBadge({required this.branch});
  final String branch;

  @override
  Widget build(BuildContext context) {
    final isOftalvision = branch.toUpperCase().contains('OFTALVISION');
    final bg = isOftalvision ? AppColors.blueBg : AppColors.successBgLight;
    final fg = isOftalvision ? AppColors.blueDark : AppColors.successDark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        branch,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: fg,
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

/// Ultra-lightweight progress bar using [FractionallySizedBox]
/// Avoids heavy Material [LinearProgressIndicator] AnimationControllers
class _PaymentProgressBar extends StatelessWidget {
  const _PaymentProgressBar({
    required this.isPaid,
    required this.total,
    required this.account,
    required this.rest,
  });

  final bool isPaid;
  final double total;
  final double account;
  final double rest;

  @override
  Widget build(BuildContext context) {
    final percent = total > 0 ? (account / total).clamp(0.0, 1.0) : 1.0;
    final percentInt = (percent * 100).round();

    return SizedBox(
      width: 155,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        spacing: 3,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Abonó: ${account.toCurrency()}',
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.zinc600,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '$percentInt%',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: isPaid ? AppColors.successDark : AppColors.warningDark,
                ),
              ),
            ],
          ),
          // Lightweight custom progress track
          Container(
            height: 5,
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.zinc200,
              borderRadius: BorderRadius.circular(99),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: percent,
              child: Container(
                decoration: BoxDecoration(
                  color: isPaid ? AppColors.success : AppColors.warning,
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
            ),
          ),
          if (!isPaid)
            Text(
              'Resta: ${rest.toCurrency()}',
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: AppColors.error,
              ),
            )
          else
            const Text(
              'Liquidada',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: AppColors.successDark,
              ),
            ),
        ],
      ),
    );
  }
}
