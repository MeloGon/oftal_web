import 'package:flutter/material.dart';
import 'package:oftal_web/core/theme/app_colors.dart';
import 'package:oftal_web/shared/models/shared_models.dart';

enum _PatientAction { viewMeasurements, addMeasurement, edit, delete }

class PatientActions extends StatelessWidget {
  final PatientModel patient;
  final Function() onAddMeasurement;
  final Function() onViewMeasurements;
  final Function() onDeletePatient;
  final Function() onEditPatient;
  final Function()? onSelectPatientToSell;
  final bool? isForSell;

  const PatientActions({
    super.key,
    required this.patient,
    required this.onAddMeasurement,
    required this.onViewMeasurements,
    required this.onDeletePatient,
    required this.onEditPatient,
    this.onSelectPatientToSell,
    this.isForSell = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isForSell ?? false) {
      return InkWell(
        onTap: onSelectPatientToSell,
        borderRadius: BorderRadius.circular(6),
        child: const SizedBox.square(
          dimension: 28,
          child: Icon(Icons.add_shopping_cart, size: 18, color: AppColors.zinc600),
        ),
      );
    }

    return PopupMenuButton<_PatientAction>(
      icon: Icon(Icons.more_vert, size: 18, color: AppColors.zinc500),
      tooltip: '',
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      onSelected: (action) {
        switch (action) {
          case _PatientAction.viewMeasurements:
            onViewMeasurements();
          case _PatientAction.addMeasurement:
            onAddMeasurement();
          case _PatientAction.edit:
            onEditPatient();
          case _PatientAction.delete:
            onDeletePatient();
        }
      },
      itemBuilder: (_) => [
        const PopupMenuItem(
          value: _PatientAction.viewMeasurements,
          height: 36,
          child: _MenuItem(
            icon: Icons.remove_red_eye_outlined,
            label: 'Ver medidas',
          ),
        ),
        const PopupMenuItem(
          value: _PatientAction.addMeasurement,
          height: 36,
          child: _MenuItem(
            icon: Icons.add_circle_outline_sharp,
            label: 'Agregar medida',
          ),
        ),
        const PopupMenuItem(
          value: _PatientAction.edit,
          height: 36,
          child: _MenuItem(
            icon: Icons.edit_outlined,
            label: 'Editar paciente',
            color: AppColors.sky,
          ),
        ),
        const PopupMenuDivider(height: 1),
        const PopupMenuItem(
          value: _PatientAction.delete,
          height: 36,
          child: _MenuItem(
            icon: Icons.delete_outline_outlined,
            label: 'Eliminar',
            color: AppColors.error,
          ),
        ),
      ],
    );
  }
}

class _MenuItem extends StatelessWidget {
  const _MenuItem({required this.icon, required this.label, this.color});
  final IconData icon;
  final String label;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppColors.zinc900;
    return Row(
      spacing: 8,
      children: [
        Icon(icon, size: 16, color: c),
        Text(label, style: TextStyle(fontSize: 13, color: c)),
      ],
    );
  }
}
