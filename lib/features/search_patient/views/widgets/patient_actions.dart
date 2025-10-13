import 'package:flutter/material.dart';
import 'package:oftal_web/shared/models/shared_models.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class PatientActions extends StatelessWidget {
  final PatientModel patient;
  final Function() onAddMeasurement;
  final Function() onViewMeasurements;
  final Function() onDeletePatient;
  const PatientActions({
    super.key,
    required this.patient,
    required this.onAddMeasurement,
    required this.onViewMeasurements,
    required this.onDeletePatient,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: 10,
      children: [
        ShadTooltip(
          builder: (context) => const Text('Ver mediciones'),
          child: InkWell(
            onTap: onViewMeasurements,
            child: Icon(Icons.remove_red_eye_outlined, size: 20),
          ),
        ),
        ShadTooltip(
          builder: (context) => const Text('Agregar medición'),
          child: InkWell(
            onTap: onAddMeasurement,
            child: Icon(
              Icons.add_circle_outline_sharp,
              size: 20,
            ),
          ),
        ),
        ShadTooltip(
          builder: (context) => const Text('Eliminar paciente'),
          child: InkWell(
            onTap: onDeletePatient,
            child: Icon(
              Icons.delete_outline_outlined,
              size: 20,
            ),
          ),
        ),
      ],
    );
  }
}
