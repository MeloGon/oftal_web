import 'package:flutter/material.dart';
import 'package:oftal_web/shared/models/shared_models.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class ResinInventoryActions extends StatelessWidget {
  final ResinModel resin;
  final Function() onDeleteResin;
  final Function() onEditResin;
  const ResinInventoryActions({
    super.key,
    required this.resin,
    required this.onDeleteResin,
    required this.onEditResin,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: 10,
      children: [
        ShadTooltip(
          builder: (context) => const Text('Editar'),
          child: InkWell(
            onTap: onEditResin,
            child: Icon(Icons.edit_outlined, size: 20),
          ),
        ),
        ShadTooltip(
          builder: (context) => const Text('Eliminar'),
          child: InkWell(
            onTap: onDeleteResin,
            child: Icon(Icons.delete_outlined, size: 20),
          ),
        ),
      ],
    );
  }
}
