import 'package:flutter/material.dart';
import 'package:oftal_web/shared/models/shared_models.dart';

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
    return Row(
      spacing: 8,
      children: [
        if (isForSell ?? false) ...[
          _ActionIcon(
            icon: Icons.add_shopping_cart,
            onTap: onSelectPatientToSell,
          ),
        ] else ...[
          _ActionIcon(
            icon: Icons.remove_red_eye_outlined,
            tooltip: 'Ver medidas',
            onTap: onViewMeasurements,
          ),
          _ActionIcon(
            icon: Icons.add_circle_outline_sharp,
            tooltip: 'Agregar medida',
            onTap: onAddMeasurement,
          ),
          _ActionIcon(
            icon: Icons.edit_outlined,
            tooltip: 'Editar paciente',
            color: const Color(0xff0EA5E9),
            onTap: onEditPatient,
          ),
          _ActionIcon(
            icon: Icons.delete_outline_outlined,
            tooltip: 'Eliminar',
            color: Colors.red,
            onTap: onDeletePatient,
          ),
        ],
      ],
    );
  }
}

class _ActionIcon extends StatelessWidget {
  const _ActionIcon({
    required this.icon,
    this.onTap,
    this.tooltip,
    this.color,
  });

  final IconData icon;
  final VoidCallback? onTap;
  final String? tooltip;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final w = InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: SizedBox.square(
        dimension: 28,
        child: Icon(icon, size: 18, color: color ?? const Color(0xff52525B)),
      ),
    );
    if (tooltip != null) return Tooltip(message: tooltip!, child: w);
    return w;
  }
}
