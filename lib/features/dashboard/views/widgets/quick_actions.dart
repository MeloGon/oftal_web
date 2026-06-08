import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:oftal_web/core/theme/app_colors.dart';
import 'package:oftal_web/router/app_router.dart';
import 'package:oftal_web/router/router_name.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class QuickActions extends StatelessWidget {
  const QuickActions({super.key, required this.ref});
  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    return ShadCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 12,
        children: [
          const Text(
            'Accesos rápidos',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.zinc900,
            ),
          ),
          ActionButton(
            icon: Icons.point_of_sale_outlined,
            label: 'Nueva venta',
            color: AppColors.primary,
            bg: AppColors.primaryBg,
            onTap: () => ref.read(appRouterProvider).go(RouterName.sell),
          ),
          ActionButton(
            icon: Icons.manage_search_outlined,
            label: 'Buscar paciente',
            color: AppColors.sky,
            bg: AppColors.skyBg,
            onTap: () =>
                ref.read(appRouterProvider).go(RouterName.searchPatient),
          ),
          ActionButton(
            icon: Icons.receipt_long_outlined,
            label: 'Historial de ventas',
            color: AppColors.emerald,
            bg: AppColors.emeraldBg,
            onTap: () =>
                ref.read(appRouterProvider).go(RouterName.salesHistory),
          ),
          ActionButton(
            icon: Icons.person_add_outlined,
            label: 'Agregar paciente',
            color: AppColors.warningDark,
            bg: AppColors.warningBgLight,
            onTap: () =>
                ref.read(appRouterProvider).go(RouterName.addPatient),
          ),
        ],
      ),
    );
  }
}

class ActionButton extends StatefulWidget {
  const ActionButton({
    super.key,
    required this.icon,
    required this.label,
    required this.color,
    required this.bg,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final Color bg;
  final VoidCallback onTap;

  @override
  State<ActionButton> createState() => ActionButtonState();
}

class ActionButtonState extends State<ActionButton> {
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
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: _hovered ? widget.bg : AppColors.zinc50,
            border: Border.all(
              color: _hovered ? widget.color.withValues(alpha: 0.4) : AppColors.zinc200,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            spacing: 10,
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: widget.bg,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(widget.icon, size: 15, color: widget.color),
              ),
              Text(
                widget.label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: _hovered ? widget.color : AppColors.zinc700,
                ),
              ),
              const Spacer(),
              Icon(
                Icons.arrow_forward_rounded,
                size: 14,
                color: _hovered ? widget.color : AppColors.zinc400,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
