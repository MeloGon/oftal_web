import 'package:flutter/material.dart';
import 'package:oftal_web/core/theme/app_colors.dart';
import 'package:oftal_web/features/dashboard/viewmodels/dashboard_state.dart';

String greeting() {
  final h = DateTime.now().hour;
  if (h < 12) return 'Buenos días';
  if (h < 19) return 'Buenas tardes';
  return 'Buenas noches';
}

String spanishDate() {
  const months = [
    'enero', 'febrero', 'marzo', 'abril', 'mayo', 'junio',
    'julio', 'agosto', 'septiembre', 'octubre', 'noviembre', 'diciembre',
  ];
  const days = [
    'lunes', 'martes', 'miércoles', 'jueves', 'viernes', 'sábado', 'domingo',
  ];
  final n = DateTime.now();
  final day = days[n.weekday - 1];
  return '${day[0].toUpperCase()}${day.substring(1)}, ${n.day} de ${months[n.month - 1]} de ${n.year}';
}

class GreetingBanner extends StatelessWidget {
  const GreetingBanner({super.key, required this.state});
  final DashboardState state;

  @override
  Widget build(BuildContext context) {
    final name =
        state.userName.isNotEmpty ? ', ${state.userName.split(' ').first}' : '';
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.primaryLight],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 4,
              children: [
                Text(
                  '${greeting()}$name 👋',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                Text(
                  spanishDate(),
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                ),
                if (state.branchName.isNotEmpty)
                  Container(
                    margin: const EdgeInsets.only(top: 4),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '📍 ${state.branchName}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Icon(
            Icons.bubble_chart_outlined,
            size: 64,
            color: Colors.white.withValues(alpha: 0.15),
          ),
        ],
      ),
    );
  }
}
