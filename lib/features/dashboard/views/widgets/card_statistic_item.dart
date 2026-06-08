import 'package:flutter/material.dart';
import 'package:oftal_web/core/theme/app_colors.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class CardStatisticItem extends StatelessWidget {
  const CardStatisticItem({
    super.key,
    required this.title,
    required this.content,
    this.icon = Icons.bar_chart_outlined,
    this.iconColor = AppColors.primary,
    this.iconBgColor = AppColors.primaryBg,
  });

  final String title;
  final String content;
  final IconData icon;
  final Color iconColor;
  final Color iconBgColor;

  @override
  Widget build(BuildContext context) {
    return ShadCard(
      padding: const EdgeInsets.all(20),
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          spacing: 12,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: iconBgColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, size: 16, color: iconColor),
                ),
              ],
            ),
            Text(
              content.isEmpty ? '—' : content,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color: AppColors.zinc900,
                height: 1,
              ),
            ),
          ],
        ),
    );
  }
}
