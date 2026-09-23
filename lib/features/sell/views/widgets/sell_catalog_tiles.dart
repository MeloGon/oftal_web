import 'package:flutter/material.dart';
import 'package:oftal_web/core/theme/app_colors.dart';
import 'package:oftal_web/features/sell/views/widgets/add_to_sale_button.dart';
import 'package:oftal_web/shared/extensions/extensions.dart';
import 'package:oftal_web/shared/models/shared_models.dart';
import 'package:oftal_web/shared/widgets/field_chip.dart';

/// Compact catalog row for a mount in the sell flow.
class MountSellTile extends StatelessWidget {
  const MountSellTile({super.key, required this.mount, required this.onAdd});
  final MountModel mount;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return _SellCatalogTile(
      title: '${mount.brand} ${mount.model}',
      chips: [
        ('Color', mount.color),
        ('Descripción', mount.description),
        ('Óptica', mount.opticName),
      ],
      price: mount.price.toCurrency(),
      onAdd: onAdd,
    );
  }
}

/// Compact catalog row for a resin in the sell flow.
class ResinSellTile extends StatelessWidget {
  const ResinSellTile({super.key, required this.resin, required this.onAdd});
  final ResinModel resin;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return _SellCatalogTile(
      title: resin.description ?? '—',
      chips: [
        ('Diseño', resin.design),
        ('Línea', resin.line),
        ('Material', resin.material),
        ('Tecnología', resin.technology),
        ('Cant.', resin.quantity?.toString()),
        ('P. interno', resin.priceInternal?.toCurrency()),
      ],
      price: resin.price?.toCurrency() ?? '—',
      onAdd: onAdd,
    );
  }
}

class _SellCatalogTile extends StatelessWidget {
  const _SellCatalogTile({
    required this.title,
    required this.chips,
    required this.price,
    required this.onAdd,
  });
  final String title;
  final List<(String, String?)> chips;
  final String price;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        spacing: 12,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 3,
              children: [
                Text(
                  title,
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
          Text(
            price,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.successDark,
            ),
          ),
          AddToSaleButton(onTap: onAdd),
        ],
      ),
    );
  }
}
