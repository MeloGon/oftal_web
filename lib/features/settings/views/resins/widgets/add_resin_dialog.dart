import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:oftal_web/features/settings/viewmodels/resins/resins_provider.dart';
import 'package:oftal_web/shared/extensions/widget_extension.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class AddResinDialog {
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
              'Agregar Resina',
            ),
            description: Text('Ingresa los datos del producto'),
            actions: [
              ShadButton(
                onPressed: () {
                  ref.read(resinsProvider.notifier).addResin();
                  Navigator.of(context).pop();
                },
                child: Text('Guardar'),
              ),
              ShadButton(
                onPressed: () {
                  ref.read(resinsProvider.notifier).closeAddResinDialog();
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
    final resinsNotifier = ref.read(resinsProvider.notifier);
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.8,
      height: MediaQuery.of(context).size.height * 0.8,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          spacing: 16,
          children: [
            _buildInputField(
              'Descripción',
              resinsNotifier.descriptionController,
            ),
            Row(
              spacing: 8,
              children: [
                _buildInputField(
                  'Diseño',
                  resinsNotifier.designController,
                ).expanded(),
                _buildInputField(
                  'Linea',
                  resinsNotifier.lineController,
                ).expanded(),
              ],
            ),
            Row(
              spacing: 8,
              children: [
                _buildInputField(
                  'Material',
                  resinsNotifier.materialController,
                ).expanded(),
                _buildInputField(
                  'Tecnología',
                  resinsNotifier.technologyController,
                ).expanded(),
              ],
            ),
            Wrap(
              direction: Axis.horizontal,
              spacing: 20,
              runSpacing: 10,
              children: [
                _buildInputField(
                  'Precio para publico',
                  resinsNotifier.priceController,
                  placeholder: 'Ej: 20.70 o 20',
                ).box(width: 150),
                _buildInputField(
                  'Precio interno',
                  resinsNotifier.priceInternalController,
                  placeholder: 'Ej: 20.70 o 20',
                ).box(width: 150),
                _buildInputField(
                  'Cantidad',
                  resinsNotifier.quantityController,
                  placeholder: 'Ej: 10',
                ).box(width: 100),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField(
    String label,
    TextEditingController controller, {
    int maxLines = 1,
    String? placeholder,
  }) {
    return ShadInputFormField(
      label: Text(label),
      controller: controller,
      maxLines: maxLines,
      keyboardType: _getKeyboardType(label),
      placeholder: Text(placeholder ?? ''),
    );
  }

  TextInputType _getKeyboardType(String label) {
    if (label.contains('Precio') || label.contains('Cantidad')) {
      return TextInputType.number;
    }
    return TextInputType.text;
  }
}
