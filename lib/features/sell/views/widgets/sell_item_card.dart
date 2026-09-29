import 'package:flutter/material.dart';
import 'package:oftal_web/core/theme/app_colors.dart';
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
    final isMount = (item.mountBrand != null && item.mountBrand!.isNotEmpty) ||
        (item.idMount != null && item.idMount! > 0);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.zinc50,
        border: Border.all(color: AppColors.zinc200),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        spacing: 12,
        children: [
          // Icono según tipo (Montura vs Resina)
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: isMount ? AppColors.indigoBg : AppColors.blueBg,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              isMount
                  ? Icons.visibility_outlined
                  : Icons.blur_circular_outlined,
              size: 18,
              color: isMount ? AppColors.indigo : AppColors.blue,
            ),
          ),

          // Información del producto
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 2,
              children: [
                Row(
                  spacing: 6,
                  children: [
                    Flexible(
                      child: Text(
                        item.mountBrand ?? item.description ?? 'Producto',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.zinc900,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 5,
                        vertical: 1,
                      ),
                      decoration: BoxDecoration(
                        color: isMount ? AppColors.indigoBg : AppColors.blueBg,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        isMount ? 'Montura' : 'Resina',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          color: isMount ? AppColors.indigo : AppColors.blue,
                        ),
                      ),
                    ),
                  ],
                ),
                Text(
                  item.mountModel ?? item.design ?? '',
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.zinc500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          // Edición de precio con prefijo
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            spacing: 2,
            children: [
              SizedBox(
                width: 115,
                child: ShadInput(
                  controller: _priceCtrl,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  onSubmitted: (_) => _commit(),
                  onEditingComplete: _commit,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  leading: const Padding(
                    padding: EdgeInsets.only(right: 2),
                    child: Text(
                      'S/.',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppColors.zinc400,
                      ),
                    ),
                  ),
                ),
              ),
              Text(
                'Cant. ${item.mountQuantity ?? item.quantity ?? '1'}',
                style: const TextStyle(fontSize: 10, color: AppColors.zinc500),
              ),
            ],
          ),

          // Botón de eliminar
          Tooltip(
            message: 'Eliminar producto',
            child: Material(
              type: MaterialType.transparency,
              child: InkWell(
                onTap: widget.onRemove,
                borderRadius: BorderRadius.circular(6),
                child: Padding(
                  padding: const EdgeInsets.all(6),
                  child: Icon(
                    Icons.delete_outline,
                    size: 18,
                    color: Colors.red.shade400,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
