import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:oftal_web/shared/models/shared_models.dart';

enum _SaleAction { viewDetails, print, registerPayment, finalize, changeDate, delete }

class SalesHistoryActions extends StatelessWidget {
  const SalesHistoryActions({
    super.key,
    required this.sale,
    required this.onViewDetails,
    required this.onDeleteSale,
    required this.onPrintSale,
    required this.onFinalizeSale,
    required this.onRegisterPayment,
    required this.onChangeDate,
    this.changeDateEnabled = true,
  });
  final SalesModel sale;
  final VoidCallback onViewDetails;
  final VoidCallback onDeleteSale;
  final VoidCallback onPrintSale;
  final VoidCallback onFinalizeSale;
  final VoidCallback onRegisterPayment;
  final ValueChanged<DateTime> onChangeDate;
  final bool changeDateEnabled;

  @override
  Widget build(BuildContext context) {
    final hasPending = (sale.rest ?? 0) > 0;

    return PopupMenuButton<_SaleAction>(
      icon: const Icon(Icons.more_vert, size: 18, color: Color(0xff71717A)),
      tooltip: '',
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      onSelected: (action) async {
        switch (action) {
          case _SaleAction.viewDetails:
            onViewDetails();
          case _SaleAction.print:
            onPrintSale();
          case _SaleAction.registerPayment:
            onRegisterPayment();
          case _SaleAction.finalize:
            onFinalizeSale();
          case _SaleAction.changeDate:
            final initial = _parseSaleDate(sale.updatedDate ?? sale.date);
            final picked = await showDatePicker(
              context: context,
              initialDate: initial,
              firstDate: DateTime(2000),
              lastDate: DateTime.now(),
              locale: const Locale('es', 'MX'),
            );
            if (picked != null) onChangeDate(picked);
          case _SaleAction.delete:
            onDeleteSale();
        }
      },
      itemBuilder: (_) => [
        const PopupMenuItem(
          value: _SaleAction.viewDetails,
          height: 36,
          child: _MenuItem(
            icon: Icons.remove_red_eye_outlined,
            label: 'Ver detalles',
          ),
        ),
        const PopupMenuItem(
          value: _SaleAction.print,
          height: 36,
          child: _MenuItem(icon: Icons.print_outlined, label: 'Imprimir recibo'),
        ),
        if (hasPending) ...[
          const PopupMenuItem(
            value: _SaleAction.registerPayment,
            height: 36,
            child: _MenuItem(
              icon: Icons.account_balance_wallet_outlined,
              label: 'Registrar abono',
              color: Color(0xff7A6BF5),
            ),
          ),
          const PopupMenuItem(
            value: _SaleAction.finalize,
            height: 36,
            child: _MenuItem(
              icon: Icons.check_circle_outline,
              label: 'Finalizar venta',
              color: Color(0xff16A34A),
            ),
          ),
        ],
        if (changeDateEnabled)
          const PopupMenuItem(
            value: _SaleAction.changeDate,
            height: 36,
            child: _MenuItem(
              icon: Icons.edit_calendar_outlined,
              label: 'Cambiar fecha',
            ),
          ),
        const PopupMenuDivider(height: 1),
        const PopupMenuItem(
          value: _SaleAction.delete,
          height: 36,
          child: _MenuItem(
            icon: Icons.delete_outlined,
            label: 'Eliminar',
            color: Color(0xffEF4444),
          ),
        ),
      ],
    );
  }
}

DateTime _parseSaleDate(String? raw) {
  if (raw == null || raw.isEmpty) return DateTime.now();
  try {
    return DateFormat('dd-MMM-yy', 'en_US').parse(raw);
  } catch (_) {}
  try {
    return DateTime.parse(raw);
  } catch (_) {}
  return DateTime.now();
}

class _MenuItem extends StatelessWidget {
  const _MenuItem({required this.icon, required this.label, this.color});
  final IconData icon;
  final String label;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final c = color ?? const Color(0xff18181B);
    return Row(
      spacing: 8,
      children: [
        Icon(icon, size: 16, color: c),
        Text(label, style: TextStyle(fontSize: 13, color: c)),
      ],
    );
  }
}
