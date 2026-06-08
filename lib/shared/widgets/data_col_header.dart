import 'package:flutter/material.dart';
import 'package:oftal_web/core/theme/app_colors.dart';

class DataColHeader extends StatelessWidget {
  const DataColHeader(this.text, {super.key});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: AppColors.zinc600,
      ),
    );
  }
}
