import 'package:flutter/material.dart';
import 'package:oftal_web/shared/models/shared_models.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class MountsInventoryActions extends StatelessWidget {
  final MountModel mount;
  final Function() onDeleteMount;
  final Function() onEditMount;
  const MountsInventoryActions({
    super.key,
    required this.mount,
    required this.onDeleteMount,
    required this.onEditMount,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: 10,
      children: [
        ShadTooltip(
          builder: (context) => const Text('Editar'),
          child: InkWell(
            onTap: onEditMount,
            child: Icon(Icons.edit_outlined, size: 20),
          ),
        ),
        ShadTooltip(
          builder: (context) => const Text('Eliminar'),
          child: InkWell(
            onTap: onDeleteMount,
            child: Icon(Icons.delete_outlined, size: 20),
          ),
        ),
      ],
    );
  }
}
