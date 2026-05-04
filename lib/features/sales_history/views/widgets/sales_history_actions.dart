import 'package:flutter/material.dart';
import 'package:oftal_web/shared/models/shared_models.dart';

class SalesHistoryActions extends StatelessWidget {
  const SalesHistoryActions({
    super.key,
    required this.sale,
    required this.onViewDetails,
    required this.onDeleteSale,
    required this.onPrintSale,
    required this.onEditSale,
    required this.onFinalizeSale,
    required this.onRegisterPayment,
  });
  final SalesModel sale;
  final Function() onViewDetails;
  final Function() onDeleteSale;
  final Function() onPrintSale;
  final Function() onEditSale;
  final Function() onFinalizeSale;
  final Function() onRegisterPayment;

  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: 8,
      children: [
        Tooltip(
          message: 'Ver detalles',
          child: Material(
            type: MaterialType.transparency,
            child: InkWell(
              onTap: onViewDetails,
              borderRadius: BorderRadius.circular(4),
              child: const Padding(
                padding: EdgeInsets.all(2),
                child: Icon(Icons.remove_red_eye_outlined, size: 18),
              ),
            ),
          ),
        ),
        Tooltip(
          message: 'Imprimir',
          child: Material(
            type: MaterialType.transparency,
            child: InkWell(
              onTap: onPrintSale,
              borderRadius: BorderRadius.circular(4),
              child: const Padding(
                padding: EdgeInsets.all(2),
                child: Icon(Icons.print_outlined, size: 18),
              ),
            ),
          ),
        ),
        Tooltip(
          message: 'Editar venta',
          child: Material(
            type: MaterialType.transparency,
            child: InkWell(
              onTap: onEditSale,
              borderRadius: BorderRadius.circular(4),
              child: const Padding(
                padding: EdgeInsets.all(2),
                child: Icon(
                  Icons.edit_outlined,
                  size: 18,
                  color: Color(0xff0EA5E9),
                ),
              ),
            ),
          ),
        ),
        if ((sale.rest ?? 0) > 0)
          Tooltip(
            message: 'Registrar abono',
            child: Material(
              type: MaterialType.transparency,
              child: InkWell(
                onTap: onRegisterPayment,
                borderRadius: BorderRadius.circular(4),
                child: const Padding(
                  padding: EdgeInsets.all(2),
                  child: Icon(
                    Icons.payments_outlined,
                    size: 18,
                    color: Color(0xff7A6BF5),
                  ),
                ),
              ),
            ),
          ),
        if ((sale.rest ?? 0) > 0)
          Tooltip(
            message: 'Finalizar venta',
            child: Material(
              type: MaterialType.transparency,
              child: InkWell(
                onTap: onFinalizeSale,
                borderRadius: BorderRadius.circular(4),
                child: const Padding(
                  padding: EdgeInsets.all(2),
                  child: Icon(
                    Icons.check_circle_outline,
                    size: 18,
                    color: Color(0xff16A34A),
                  ),
                ),
              ),
            ),
          ),
        Tooltip(
          message: 'Eliminar',
          child: Material(
            type: MaterialType.transparency,
            child: InkWell(
              onTap: onDeleteSale,
              borderRadius: BorderRadius.circular(4),
              child: const Padding(
                padding: EdgeInsets.all(2),
                child: Icon(Icons.delete_outlined, size: 18),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
