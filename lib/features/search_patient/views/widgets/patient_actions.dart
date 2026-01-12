import 'package:flutter/material.dart';
import 'package:oftal_web/shared/models/shared_models.dart';

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
          InkWell(
            onTap: onSelectPatientToSell,
            child: Icon(Icons.add_shopping_cart, size: 20),
          ),
        ] else ...[
          InkWell(
            onTap: onViewMeasurements,
            child: Icon(Icons.remove_red_eye_outlined, size: 20),
          ),
          InkWell(
            onTap: onAddMeasurement,
            child: Icon(
              Icons.add_circle_outline_sharp,
              size: 20,
            ),
          ),
          InkWell(
            onTap: onDeletePatient,
            child: Icon(
              Icons.delete_outline_outlined,
              size: 20,
            ),
          ),
        ],
      ],
    );
  }
}
