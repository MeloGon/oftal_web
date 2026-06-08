import 'package:flutter/material.dart';
import 'package:oftal_web/core/theme/app_colors.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class FormSectionCard extends StatelessWidget {
  const FormSectionCard({
    super.key,
    required this.title,
    this.subtitle,
    required this.icon,
    required this.child,
  });

  final String title;
  final String? subtitle;
  final IconData icon;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ShadCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 16,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 2,
            children: [
              Row(
                spacing: 8,
                children: [
                  Icon(icon, size: 16, color: AppColors.primary),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.zinc900,
                    ),
                  ),
                ],
              ),
              if (subtitle != null)
                Padding(
                  padding: const EdgeInsets.only(left: 24),
                  child: Text(
                    subtitle!,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.gray400,
                    ),
                  ),
                ),
            ],
          ),
          const Divider(height: 1),
          child,
        ],
      ),
    );
  }
}
