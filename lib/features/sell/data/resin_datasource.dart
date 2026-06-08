import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:oftal_web/core/theme/app_colors.dart';
import 'package:oftal_web/features/sell/viewmodels/sell_provider.dart';
import 'package:oftal_web/shared/extensions/extensions.dart';
import 'package:oftal_web/shared/models/shared_models.dart';

class ResinDataSource extends DataTableSource {
  final List<ResinModel> resins;
  final BuildContext context;
  final WidgetRef ref;

  ResinDataSource({
    required this.resins,
    required this.context,
    required this.ref,
  });

  static const _cell = TextStyle(fontSize: 12, color: AppColors.zinc900);
  static const _qty = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: AppColors.zinc900,
  );
  static const _price = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: AppColors.successDark,
  );

  @override
  DataRow? getRow(int index) {
    final r = resins[index];
    return DataRow.byIndex(
      index: index,
      cells: [
        DataCell(Text(r.description ?? '', style: _cell)),
        DataCell(Text(r.design ?? '', style: _cell)),
        DataCell(Text(r.line ?? '', style: _cell)),
        DataCell(Text(r.material ?? '', style: _cell)),
        DataCell(Text(r.technology ?? '', style: _cell)),
        DataCell(Text(r.quantity?.toString() ?? '', style: _qty)),
        DataCell(Text(r.priceInternal?.toCurrency() ?? '', style: _price)),
        DataCell(Text(r.price?.toCurrency() ?? '', style: _price)),
        DataCell(
          _AddButton(onTap: () => ref.read(sellProvider.notifier).selectItemToSell(r)),
        ),
      ],
    );
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => resins.length;

  @override
  int get selectedRowCount => 0;
}

class _AddButton extends StatefulWidget {
  const _AddButton({required this.onTap});
  final VoidCallback onTap;

  @override
  State<_AddButton> createState() => _AddButtonState();
}

class _AddButtonState extends State<_AddButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: _hovered ? AppColors.primary : AppColors.primaryBg,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            spacing: 4,
            children: [
              Icon(
                Icons.add_shopping_cart_rounded,
                size: 13,
                color: _hovered ? Colors.white : AppColors.primary,
              ),
              Text(
                'Agregar',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: _hovered ? Colors.white : AppColors.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
