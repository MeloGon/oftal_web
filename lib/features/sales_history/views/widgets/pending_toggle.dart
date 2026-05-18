import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class PendingToggle extends StatelessWidget {
  const PendingToggle({super.key, required this.active, required this.onTap});
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    if (active) {
      return ShadButton(
        size: ShadButtonSize.sm,
        onPressed: onTap,
        child: const Row(
          spacing: 6,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(LucideIcons.circleAlert, size: 14),
            Text('Saldo pendiente'),
          ],
        ),
      );
    }
    return ShadButton.outline(
      size: ShadButtonSize.sm,
      onPressed: onTap,
      child: const Row(
        spacing: 6,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(LucideIcons.circleAlert, size: 14),
          Text('Saldo pendiente'),
        ],
      ),
    );
  }
}
