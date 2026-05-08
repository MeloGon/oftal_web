import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class AppSpinner extends StatefulWidget {
  const AppSpinner({
    super.key,
    this.size = 20,
    this.color = const Color(0xff7A6BF5),
  });

  final double size;
  final Color color;

  @override
  State<AppSpinner> createState() => _AppSpinnerState();
}

class _AppSpinnerState extends State<AppSpinner>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RotationTransition(
      turns: _ctrl,
      child: Icon(
        LucideIcons.loaderCircle,
        size: widget.size,
        color: widget.color,
      ),
    );
  }
}
