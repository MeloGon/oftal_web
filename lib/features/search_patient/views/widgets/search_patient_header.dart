import 'package:flutter/material.dart';
import 'package:oftal_web/core/theme/app_colors.dart';

class SearchPatientHeader extends StatelessWidget {
  const SearchPatientHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 4,
      children: [
        const Text(
          'Buscar Paciente',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: AppColors.zinc900,
          ),
        ),
        Text(
          'Busca y gestiona los registros de pacientes',
          style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
        ),
      ],
    );
  }
}
