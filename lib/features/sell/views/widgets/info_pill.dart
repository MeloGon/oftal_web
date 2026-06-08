import 'package:flutter/material.dart';
import 'package:oftal_web/core/theme/app_colors.dart';

class InfoPill extends StatelessWidget {
  const InfoPill({super.key, required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      spacing: 3,
      children: [
        Icon(icon, size: 11, color: AppColors.zinc500),
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: AppColors.zinc500),
        ),
      ],
    );
  }
}
