import 'package:flutter/material.dart';
import 'package:oftal_web/core/theme/app_text_styles.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class AddPatientGuide extends StatelessWidget {
  const AddPatientGuide({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    return ShadCard(
      width: width * .9,
      child: ShadAccordion<int>(
        children: [
          ShadAccordionItem(
            value: 1,
            title: Text(
              'Presiona para desplegar o contraer instrucciones para "Agregar paciente"',
              style: AppTextStyles(context).small14Bold,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 6,
              children: [
                Text(
                  '\u2022 Recuerda ingresar todos los campos requeridos, en caso de no hacerlo te indicara cuáles son los campos requeridos',
                  style: AppTextStyles(context).small12,
                ),
                Text(
                  '\u2022 Una vez agregado el paciente te saldra un mensaje de confirmacion',
                  style: AppTextStyles(context).small12,
                ),
                Text(
                  '\u2022 Ya agregado el paciente puedes verlo desde el modulo de buscar paciente, o si deslizas mas abajo hay una lista de los ultimos 7 clientes creados',
                  style: AppTextStyles(context).small12,
                ),
                Text(
                  '\u2022 Recuerda aqui solo puedes agregar pacientes, si quieres ver medidas , agregar medidas o eliminar pacientes debes hacerlo desde el modulo de buscar paciente',
                  style: AppTextStyles(context).small12,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
