import 'package:flutter/material.dart';
import 'package:oftal_web/shared/models/shared_models.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class MountActions extends StatelessWidget {
  final MountModel mount;
  final Function() onAddToCart;
  const MountActions({
    super.key,
    required this.mount,
    required this.onAddToCart,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: 10,
      children: [
        ShadTooltip(
          builder: (context) => const Text('Agregar al carrito'),
          child: InkWell(
            onTap: onAddToCart,
            child: Icon(Icons.add_shopping_cart, size: 20),
          ),
        ),
      ],
    );
  }
}
