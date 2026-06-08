import 'package:flutter/material.dart';
import 'package:oftal_web/core/theme/app_colors.dart';
import 'package:oftal_web/shared/extensions/extensions.dart';
import 'package:oftal_web/shared/models/shared_models.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class SellItemCard extends StatefulWidget {
  const SellItemCard({
    super.key,
    required this.item,
    required this.onRemove,
    required this.onPriceChanged,
  });
  final SalesDetailsModel item;
  final VoidCallback onRemove;
  final ValueChanged<double> onPriceChanged;

  @override
  State<SellItemCard> createState() => SellItemCardState();
}

class SellItemCardState extends State<SellItemCard> {
  late final TextEditingController _priceCtrl;

  @override
  void initState() {
    super.initState();
    final price = widget.item.mountPrice ?? widget.item.price ?? 0.0;
    _priceCtrl = TextEditingController(text: price.toStringAsFixed(2));
  }

  @override
  void dispose() {
    _priceCtrl.dispose();
    super.dispose();
  }

  void _commit() {
    final parsed = double.tryParse(_priceCtrl.text);
    if (parsed != null) widget.onPriceChanged(parsed);
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.zinc50,
        border: Border.all(color: AppColors.zinc200),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 2,
              children: [
                Text(
                  item.mountBrand ?? item.description ?? '',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.zinc900,
                  ),
                ),
                Text(
                  item.mountModel ?? item.design ?? '',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.zinc500,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            spacing: 4,
            children: [
              ShadInput(
                controller: _priceCtrl,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                onSubmitted: (_) => _commit(),
                onEditingComplete: _commit,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                // prefix: const Text(
                //   's/. ',
                //   style: TextStyle(fontSize: 12, color: AppColors.zinc500),
                // ),
              ).constrained(width: 110),
              Text(
                'Cant. ${item.mountQuantity ?? item.quantity ?? ''}',
                style: const TextStyle(fontSize: 11, color: AppColors.zinc500),
              ),
            ],
          ),
          const SizedBox(width: 12),
          Material(
            type: MaterialType.transparency,
            child: InkWell(
              onTap: widget.onRemove,
              borderRadius: BorderRadius.circular(6),
              child: Padding(
                padding: const EdgeInsets.all(4),
                child: Icon(
                  Icons.delete_outline,
                  size: 18,
                  color: Colors.red.shade400,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
