import 'package:flutter/material.dart';
import 'package:oftal_web/core/theme/app_colors.dart';

class SalesHistoryPageHeader extends StatelessWidget {
  const SalesHistoryPageHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 4,
      children: [
        const Text(
          'Historial de Ventas',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: AppColors.zinc900,
          ),
        ),
        Text(
          'Consulta y filtra todas las ventas registradas',
          style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
        ),
      ],
    );
  }
}
