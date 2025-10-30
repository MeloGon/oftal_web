import 'package:flutter/material.dart';
import 'package:oftal_web/shared/models/shared_models.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class MountsInventoryActions extends StatelessWidget {
  final MountModel mount;
  // final Function() onAddToCart;
  const MountsInventoryActions({
    super.key,
    required this.mount,
    // required this.onAddToCart,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: 10,
      children: [
        ShadTooltip(
          builder: (context) => const Text('Editar'),
          child: InkWell(
            // onTap: onAddToCart,
            child: Icon(Icons.edit_outlined, size: 20),
          ),
        ),
        ShadTooltip(
          builder: (context) => const Text('Eliminar'),
          child: InkWell(
            // onTap: onDeleteResin,
            child: Icon(Icons.delete_outlined, size: 20),
          ),
        ),
      ],
    );
  }
}
