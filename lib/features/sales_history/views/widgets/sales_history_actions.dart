import 'package:flutter/material.dart';
import 'package:oftal_web/shared/models/shared_models.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class SalesHistoryActions extends StatelessWidget {
  const SalesHistoryActions({
    super.key,
    required this.sale,
    required this.onViewDetails,
    required this.onDeleteSale,
  });
  final SalesModel sale;
  final Function() onViewDetails;
  final Function() onDeleteSale;

  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: 10,
      children: [
        ShadTooltip(
          builder: (context) => const Text('Ver detalles'),
          child: InkWell(
            onTap: onViewDetails,
            child: Icon(Icons.remove_red_eye_outlined),
          ),
        ),
        ShadTooltip(
          builder: (context) => const Text('Eliminar'),
          child: InkWell(
            onTap: onDeleteSale,
            child: Icon(Icons.delete_outlined),
          ),
        ),
      ],
    );
  }
}
