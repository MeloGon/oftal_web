import 'package:flutter/material.dart';
import 'package:oftal_web/core/theme/app_text_styles.dart';
import 'package:oftal_web/shared/extensions/extensions.dart';

class MenuItem extends StatefulWidget {
  final String text;
  final IconData icon;
  final bool isActive;
  final Function onPressed;

  const MenuItem({
    super.key,
    required this.text,
    required this.icon,
    required this.onPressed,
    this.isActive = false,
  });

  @override
  MenuItemState createState() => MenuItemState();
}

class MenuItemState extends State<MenuItem> {
  bool isHovered = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color:
            isHovered
                ? Colors.white.withValues(alpha: 0.1)
                : widget.isActive
                ? Colors.white.withValues(alpha: 0.1)
                : Colors.transparent,
      ),

      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: widget.isActive ? null : () => widget.onPressed(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
            child: MouseRegion(
              onEnter: (_) => setState(() => isHovered = true),
              onExit: (_) => setState(() => isHovered = false),
              child: Row(
                spacing: 10,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(widget.icon, color: Colors.white.withValues(alpha: 0.3)),
                  Text(
                    widget.text,
                    style: AppTextStyles(context).small12.copyWith(
                      color: Colors.white.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ).marginOnly(left: 5, right: 5);
  }
}
