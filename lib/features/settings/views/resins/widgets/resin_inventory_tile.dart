import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:oftal_web/core/theme/app_colors.dart';
import 'package:oftal_web/features/settings/viewmodels/resins/resins_provider.dart';
import 'package:oftal_web/features/settings/views/resins/widgets/resins_inventory_actions.dart';
import 'package:oftal_web/shared/extensions/extensions.dart';
import 'package:oftal_web/shared/models/shared_models.dart';
import 'package:oftal_web/shared/widgets/field_chip.dart';

class ResinInventoryTile extends ConsumerWidget {
  const ResinInventoryTile({super.key, required this.resin});
  final ResinModel resin;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chips = <(String, String?)>[
      ('Diseño', resin.design),
      ('Línea', resin.line),
      ('Material', resin.material),
      ('Tecnología', resin.technology),
      ('Cant.', resin.quantity?.toString()),
      ('P. interno', resin.priceInternal?.toCurrency()),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        spacing: 14,
        children: [
          // ─ Ícono ───────────────────────────────────────
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.primaryBg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.lens_outlined,
              size: 16,
              color: AppColors.primary,
            ),
          ),

          // ─ Info ────────────────────────────────────────
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 3,
              children: [
                Text(
                  resin.description ?? '—',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.zinc900,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: [
                    for (final (label, value) in chips)
                      if (value != null && value.isNotEmpty)
                        FieldChip(label: label, value: value),
                  ],
                ),
              ],
            ),
          ),

          // ─ Precio ──────────────────────────────────────
          Text(
            (resin.price ?? 0).toCurrency(),
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.zinc900,
            ),
          ),

          // ─ Actions ─────────────────────────────────────
          ResinInventoryActions(
            resin: resin,
            onDeleteResin: () =>
                ref.read(resinsProvider.notifier).deleteResin(resin.id),
            onEditResin: () =>
                ref.read(resinsProvider.notifier).editResin(resin),
          ),
        ],
      ),
    );
  }
}
