import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class PatientsEmptyState extends StatelessWidget {
  const PatientsEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return ShadCard(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Center(
        child: Column(
          spacing: 8,
          children: [
            Icon(
              LucideIcons.users,
              size: 36,
              color: Colors.grey.shade300,
            ),
            Text(
              'Busca un paciente por su nombre',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
