import 'package:flutter/material.dart';
import 'package:oftal_web/shared/models/shared_models.dart';

class SalesHistoryActions extends StatelessWidget {
  const SalesHistoryActions({
    super.key,
    required this.sale,
    required this.onViewDetails,
    required this.onDeleteSale,
    required this.onPrintSale,
  });
  final SalesModel sale;
  final Function() onViewDetails;
  final Function() onDeleteSale;
  final Function() onPrintSale;

  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: 10,
      children: [
        InkWell(
          onTap: onViewDetails,
          child: Icon(Icons.remove_red_eye_outlined),
        ),
        InkWell(
          onTap: onPrintSale,
          child: Icon(Icons.print_outlined),
        ),
        InkWell(
          onTap: onDeleteSale,
          child: Icon(Icons.delete_outlined),
        ),
      ],
    );
  }
}
