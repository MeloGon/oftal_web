import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:oftal_web/core/theme/app_colors.dart';
import 'package:oftal_web/features/settings/viewmodels/app_features_provider.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class FeaturesToggleSection extends ConsumerWidget {
  const FeaturesToggleSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final features = ref.watch(appFeaturesProvider);

    return ShadCard(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Column(
        children: [
          _FeatureToggleRow(
            icon: Icons.edit_calendar_outlined,
            iconColor: AppColors.primary,
            iconBgColor: AppColors.primaryBg,
            title: 'Cambiar fecha de venta',
            description:
                'Permite editar la fecha de una venta desde el historial',
            value: features.changeDateEnabled,
            isLoading: features.isLoading,
            onToggle: (_) =>
                ref.read(appFeaturesProvider.notifier).toggleChangeDate(),
          ),
        ],
      ),
    );
  }
}

class _FeatureToggleRow extends StatelessWidget {
  const _FeatureToggleRow({
    required this.icon,
    required this.iconColor,
    required this.iconBgColor,
    required this.title,
    required this.description,
    required this.value,
    required this.isLoading,
    required this.onToggle,
  });

  final IconData icon;
  final Color iconColor;
  final Color iconBgColor;
  final String title;
  final String description;
  final bool value;
  final bool isLoading;
  final ValueChanged<bool> onToggle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        spacing: 14,
        children: [
          // ─ Ícono ─────────────────────────────────────────
          Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: iconBgColor,
              borderRadius: BorderRadius.circular(9),
            ),
            child: Icon(icon, size: 18, color: iconColor),
          ),

          // ─ Texto ─────────────────────────────────────────
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 2,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.zinc900,
                  ),
                ),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.zinc500,
                  ),
                ),
              ],
            ),
          ),

          // ─ Toggle ────────────────────────────────────────
          if (isLoading)
            const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          else
            ShadSwitch(
              value: value,
              onChanged: onToggle,
            ),
        ],
      ),
    );
  }
}
