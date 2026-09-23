import 'package:flutter/material.dart';
import 'package:oftal_web/core/theme/app_colors.dart';

/// "Agregar" pill used on catalog tiles in the sell flow.
class AddToSaleButton extends StatefulWidget {
  const AddToSaleButton({super.key, required this.onTap});
  final VoidCallback onTap;

  @override
  State<AddToSaleButton> createState() => _AddToSaleButtonState();
}

class _AddToSaleButtonState extends State<AddToSaleButton> {
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
