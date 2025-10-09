import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:oftal_web/features/add_patient/viewmodels/add_patient_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AddViewMeasureDialog extends ConsumerWidget {
  const AddViewMeasureDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final addPatientNotifier = ref.read(addPatientProvider.notifier);

    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.8,
      height: MediaQuery.of(context).size.height * 0.8,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 16,
          children: [
            // Información General
            _buildSectionTitle(context, 'Información General'),
            _buildInputField(
              'Motivo de Consulta',
              addPatientNotifier.reasonConsultController,
            ),
            _buildInputField(
              'Historia Clínica',
              addPatientNotifier.clinicHistoryController,
            ),
            _buildInputField(
              'Tipo de Graduación',
              addPatientNotifier.graduationTypeController,
            ),
            _buildInputField(
              'Diagnóstico Optométrico',
              addPatientNotifier.optometricDiagnosisController,
            ),

            // Ojo Derecho (OD)
            _buildSectionTitle(context, 'Ojo Derecho (OD)'),
            Row(
              children: [
                Expanded(
                  child: _buildInputField(
                    'ESF',
                    addPatientNotifier.odEsfController,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildInputField(
                    'CIL',
                    addPatientNotifier.odCilController,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildInputField(
                    'EJE',
                    addPatientNotifier.odEjeController,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildInputField(
                    'AV',
                    addPatientNotifier.odAvController,
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: _buildInputField(
                    'CB LC',
                    addPatientNotifier.odCbLcController,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildInputField(
                    'DIAM LC',
                    addPatientNotifier.odDiamLcController,
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: _buildInputField(
                    'AV SIN RX LEJOS',
                    addPatientNotifier.avSinRxOdLejosController,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildInputField(
                    'CV LEJOS',
                    addPatientNotifier.cvOdLejosController,
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: _buildInputField(
                    'AV SIN RX CERCA',
                    addPatientNotifier.avSinRxOdCercaController,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildInputField(
                    'AV CON RX CERCA',
                    addPatientNotifier.avConRxOdCercaController,
                  ),
                ),
              ],
            ),

            // Ojo Izquierdo (OI)
            _buildSectionTitle(context, 'Ojo Izquierdo (OI)'),
            Row(
              children: [
                Expanded(
                  child: _buildInputField(
                    'ESF',
                    addPatientNotifier.oiEsfController,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildInputField(
                    'CIL',
                    addPatientNotifier.oiCilController,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildInputField(
                    'EJE',
                    addPatientNotifier.oiEjeController,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildInputField(
                    'AV',
                    addPatientNotifier.oiAvController,
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: _buildInputField(
                    'CB LC',
                    addPatientNotifier.oiCbLcController,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildInputField(
                    'DIAM LC',
                    addPatientNotifier.oiDiamLcController,
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: _buildInputField(
                    'AV SIN RX LEJOS',
                    addPatientNotifier.avSinRxOiLejosController,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildInputField(
                    'CV LEJOS',
                    addPatientNotifier.cvOiLejosController,
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: _buildInputField(
                    'AV SIN RX CERCA',
                    addPatientNotifier.avSinRxOiCercaController,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildInputField(
                    'AV CON RX CERCA',
                    addPatientNotifier.avConRxOiCercaController,
                  ),
                ),
              ],
            ),

            // Campos Adicionales
            _buildSectionTitle(context, 'Campos Adicionales'),
            _buildInputField('ADD', addPatientNotifier.addController),
            _buildInputField('DIP', addPatientNotifier.dipController),
            _buildInputField(
              'Observaciones',
              addPatientNotifier.observationReviewController,
              maxLines: 3,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 8),
      child: Text(
        title,
        style: ShadTheme.of(context).textTheme.h4,
      ),
    );
  }

  Widget _buildInputField(
    String label,
    TextEditingController controller, {
    int maxLines = 1,
  }) {
    return ShadInputFormField(
      label: Text(label),
      controller: controller,
      maxLines: maxLines,
      keyboardType: _getKeyboardType(label),
    );
  }

  TextInputType _getKeyboardType(String label) {
    if (label.contains('ESF') ||
        label.contains('CIL') ||
        label.contains('EJE') ||
        label.contains('AV') ||
        label.contains('ADD') ||
        label.contains('DIP') ||
        label.contains('CB') ||
        label.contains('DIAM') ||
        label.contains('CV')) {
      return TextInputType.number;
    }
    return TextInputType.text;
  }
}
