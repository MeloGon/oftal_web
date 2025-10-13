import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:oftal_web/features/search_patient/viewmodels/search_patient_provider.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class AddReviewDialog {
  Future<void> show(
    BuildContext context,
    WidgetRef ref,
  ) async {
    return showShadDialog(
      barrierDismissible: false,
      context: context,
      builder:
          (context) => ShadDialog(
            closeIcon: SizedBox(),
            constraints: BoxConstraints(
              maxWidth: MediaQuery.sizeOf(context).width * .6,
              minWidth: 293,
            ),
            title: Text(
              'Agregar Medición para ${ref.read(searchPatientProvider).patientName}',
            ),
            description: Text('Ingresa los datos de la medición'),
            actions: [
              ShadButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('Guardar'),
              ),
              ShadButton(
                onPressed: () {
                  ref
                      .read(searchPatientProvider.notifier)
                      .closeAddViewMeasureDialog();
                  Navigator.of(context).pop();
                },
                child: Text('Cerrar'),
              ),
            ],
            child: AddReviewWidget(),
          ),
    );
  }
}

class AddReviewWidget extends ConsumerWidget {
  const AddReviewWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchPatientNotifier = ref.read(searchPatientProvider.notifier);
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
              searchPatientNotifier.reasonConsultController,
            ),
            _buildInputField(
              'Historia Clínica',
              searchPatientNotifier.clinicHistoryController,
            ),
            _buildInputField(
              'Tipo de Graduación',
              searchPatientNotifier.graduationTypeController,
            ),
            _buildInputField(
              'Diagnóstico Optométrico',
              searchPatientNotifier.optometricDiagnosisController,
            ),

            // Ojo Derecho (OD)
            _buildSectionTitle(context, 'Ojo Derecho (OD)'),
            Row(
              children: [
                Expanded(
                  child: _buildInputField(
                    'ESF',
                    searchPatientNotifier.odEsfController,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildInputField(
                    'CIL',
                    searchPatientNotifier.odCilController,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildInputField(
                    'EJE',
                    searchPatientNotifier.odEjeController,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildInputField(
                    'AV',
                    searchPatientNotifier.odAvController,
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: _buildInputField(
                    'CB LC',
                    searchPatientNotifier.odCbLcController,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildInputField(
                    'DIAM LC',
                    searchPatientNotifier.odDiamLcController,
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: _buildInputField(
                    'AV SIN RX LEJOS',
                    searchPatientNotifier.avSinRxOdLejosController,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildInputField(
                    'CV LEJOS',
                    searchPatientNotifier.cvOdLejosController,
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: _buildInputField(
                    'AV SIN RX CERCA',
                    searchPatientNotifier.avSinRxOdCercaController,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildInputField(
                    'AV CON RX CERCA',
                    searchPatientNotifier.avConRxOdCercaController,
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
                    searchPatientNotifier.oiEsfController,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildInputField(
                    'CIL',
                    searchPatientNotifier.oiCilController,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildInputField(
                    'EJE',
                    searchPatientNotifier.oiEjeController,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildInputField(
                    'AV',
                    searchPatientNotifier.oiAvController,
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: _buildInputField(
                    'CB LC',
                    searchPatientNotifier.oiCbLcController,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildInputField(
                    'DIAM LC',
                    searchPatientNotifier.oiDiamLcController,
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: _buildInputField(
                    'AV SIN RX LEJOS',
                    searchPatientNotifier.avSinRxOiLejosController,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildInputField(
                    'CV LEJOS',
                    searchPatientNotifier.cvOiLejosController,
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: _buildInputField(
                    'AV SIN RX CERCA',
                    searchPatientNotifier.avSinRxOiCercaController,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildInputField(
                    'AV CON RX CERCA',
                    searchPatientNotifier.avConRxOiCercaController,
                  ),
                ),
              ],
            ),

            // Campos Adicionales
            _buildSectionTitle(context, 'Campos Adicionales'),
            _buildInputField('ADD', searchPatientNotifier.addController),
            _buildInputField('DIP', searchPatientNotifier.dipController),
            _buildInputField(
              'Observaciones',
              searchPatientNotifier.observationReviewController,
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
