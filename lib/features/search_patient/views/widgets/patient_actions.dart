import 'package:flutter/material.dart';
import 'package:oftal_web/shared/models/shared_models.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class PatientActions extends StatelessWidget {
  final PatientModel patient;
  final Function() onAddMeasurement;
  final Function() onViewMeasurements;
  final Function() onDeletePatient;
  final Function()? onSelectPatientToSell;
  final bool? isForSell;
  const PatientActions({
    super.key,
    required this.patient,
    required this.onAddMeasurement,
    required this.onViewMeasurements,
    required this.onDeletePatient,
    this.onSelectPatientToSell,
    this.isForSell = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: 10,
      children: [
        if (isForSell ?? false) ...[
          ShadTooltip(
            builder: (context) => const Text('Agregar al carrito'),
            child: InkWell(
              onTap: onSelectPatientToSell,
              child: Icon(Icons.add_shopping_cart, size: 20),
            ),
          ),
        ] else ...[
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
      ],
    );
  }
}
