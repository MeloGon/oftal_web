import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:oftal_web/features/settings/viewmodels/mounts/mounts_provider.dart';
import 'package:oftal_web/shared/extensions/widget_extension.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class AddMountDialog {
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
              'Agregar Montura',
            ),
            description: Text('Ingresa los datos del producto'),
            actions: [
              ShadButton(
                onPressed: () {
                  ref.read(mountsProvider.notifier).addMount();
                  Navigator.of(context).pop();
                },
                child: Text('Guardar'),
              ),
              ShadButton(
                onPressed: () {
                  ref.read(mountsProvider.notifier).closeAddMountDialog();
                  Navigator.of(context).pop();
                },
                child: Text('Cerrar'),
              ),
            ],
            child: AddMountWidget(),
          ),
    );
  }
}

class AddMountWidget extends ConsumerWidget {
  const AddMountWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mountsNotifier = ref.read(mountsProvider.notifier);
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
              mountsNotifier.descriptionController,
            ),
            Row(
              spacing: 8,
              children: [
                _buildInputField(
                  'Marca',
                  mountsNotifier.brandController,
                ).expanded(),
                _buildInputField(
                  'Modelo',
                  mountsNotifier.modelController,
                ).expanded(),
              ],
            ),
            Row(
              spacing: 8,
              children: [
                _buildInputField(
                  'Color',
                  mountsNotifier.colorController,
                ).expanded(),
                _buildInputField(
                  'Proveedor',
                  mountsNotifier.providerController,
                ).expanded(),
              ],
            ),
            Wrap(
              direction: Axis.horizontal,
              spacing: 20,
              runSpacing: 10,
              children: [
                _buildInputField(
                  'Precio',
                  mountsNotifier.priceController,
                  placeholder: 'Ej: 20.70 o 20',
                ).box(width: 150),
                // _buildInputField(
                //   'Precio interno',
                //   resinsNotifier.priceInternalController,
                //   placeholder: 'Ej: 20.70 o 20',
                // ).box(width: 150),
                _buildInputField(
                  'Existencias',
                  mountsNotifier.existencesController,
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
