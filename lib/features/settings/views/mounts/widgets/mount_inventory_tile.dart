import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:oftal_web/core/theme/app_colors.dart';
import 'package:oftal_web/features/settings/viewmodels/mounts/mounts_provider.dart';
import 'package:oftal_web/features/settings/views/mounts/widgets/mounts_inventory_actions.dart';
import 'package:oftal_web/shared/extensions/extensions.dart';
import 'package:oftal_web/shared/models/shared_models.dart';
import 'package:oftal_web/shared/widgets/field_chip.dart';

class MountInventoryTile extends ConsumerWidget {
  const MountInventoryTile({super.key, required this.mount});
  final MountModel mount;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final outOfStock = mount.stock <= 0;

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
              Icons.visibility_outlined,
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
                  '${mount.brand} ${mount.model}'.toUpperCase(),
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
                    if (mount.color.isNotEmpty)
                      FieldChip(
                        label: 'Color',
                        value: mount.color.toUpperCase(),
                      ),
                    if (mount.description.isNotEmpty)
                      FieldChip(
                        label: 'Descripción',
                        value: mount.description.toUpperCase(),
                      ),
                    if (mount.opticName.isNotEmpty)
                      FieldChip(label: 'Óptica', value: mount.opticName),
                  ],
                ),
              ],
            ),
          ),

          // ─ Precio / stock ──────────────────────────────
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            spacing: 2,
            children: [
              Text(
                mount.price.toCurrency(),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.zinc900,
                ),
              ),
              Text(
                'Stock: ${mount.stock}',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: outOfStock ? AppColors.error : AppColors.zinc500,
                ),
              ),
            ],
          ),

          // ─ Actions ─────────────────────────────────────
          MountsInventoryActions(
            mount: mount,
            onDeleteMount: () =>
                ref.read(mountsProvider.notifier).deleteMount(mount.id),
            onEditMount: () =>
                ref.read(mountsProvider.notifier).editMount(mount),
          ),
        ],
      ),
    );
  }
}
