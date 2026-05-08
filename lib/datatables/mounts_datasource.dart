import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:oftal_web/features/sell/viewmodels/sell_provider.dart';
import 'package:oftal_web/shared/extensions/extensions.dart';
import 'package:oftal_web/shared/models/shared_models.dart';

class MountsDataSource extends DataTableSource {
  final List<MountModel> mounts;
  final BuildContext context;
  final WidgetRef ref;

  MountsDataSource({
    required this.mounts,
    required this.context,
    required this.ref,
  });

  static const _cell = TextStyle(fontSize: 12, color: Color(0xff18181B));
  static const _price = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: Color(0xff16A34A),
  );

  @override
  DataRow? getRow(int index) {
    final m = mounts[index];
    return DataRow.byIndex(
      index: index,
      cells: [
        DataCell(Text(m.brand, style: _cell)),
        DataCell(Text(m.model, style: _cell)),
        DataCell(Text(m.color, style: _cell)),
        DataCell(Text(m.description, style: _cell)),
        DataCell(Text(m.opticName, style: _cell)),
        DataCell(Text(m.price.toCurrency(), style: _price)),
        DataCell(
          _AddButton(onTap: () => ref.read(sellProvider.notifier).selectItemToSell(m)),
        ),
      ],
    );
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => mounts.length;

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
            color: _hovered ? const Color(0xff7A6BF5) : const Color(0xffEEECFE),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            spacing: 4,
            children: [
              Icon(
                Icons.add_shopping_cart_rounded,
                size: 13,
                color: _hovered ? Colors.white : const Color(0xff7A6BF5),
              ),
              Text(
                'Agregar',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: _hovered ? Colors.white : const Color(0xff7A6BF5),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
