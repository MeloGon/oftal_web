import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class AddPatientView extends ConsumerWidget {
  const AddPatientView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final genderOptions = {
      'Masculino': 'Masculino',
      'Femenino': 'Femenino',
      'Otro': 'Otro',
    };
    return Container(
      margin: EdgeInsets.only(top: 50),
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: ShadCard(
        child: ListView(
          shrinkWrap: true,
          children: [
            Wrap(
              spacing: 20,
              runSpacing: 20,
              children: [
                ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: 200),
                  child: ShadInputFormField(
                    label: Text('Identificación'),
                  ),
                ),
                ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: 200),
                  child: ShadInputFormField(
                    readOnly: true,
                    label: Text('ID Unico'),
                  ),
                ),
                ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: 200),
                  child: ShadInputFormField(
                    label: Text('Fecha de registro'),
                  ),
                ),
                ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: 200),
                  child: ShadInputFormField(
                    label: Text('Sucursal de registro'),
                  ),
                ),
                ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: 360),
                  child: ShadInputFormField(
                    label: Text('Apellidos y Nombres'),
                  ),
                ),
                ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: 200),
                  child: ShadDatePickerFormField(
                    height: 36,
                    label: Text('Fecha de nacimiento'),
                    placeholder: Text('Fecha de nacimiento'),
                  ),
                ),
                ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: 80),
                  child: ShadInputFormField(
                    label: Text('Edad'),
                  ),
                ),
                ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: 200),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 7.5,
                    children: [
                      Text('Género'),
                      ShadSelect<String>(
                        placeholder: Text('Género'),
                        selectedOptionBuilder: (context, value) => Text(value),
                        options:
                            genderOptions.entries
                                .map(
                                  (e) => ShadOption(
                                    value: e.key,
                                    child: Text(e.value),
                                  ),
                                )
                                .toList(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            ShadButton(
              child: Text('Guardar'),
              onPressed: () {},
            ),
          ],
        ),
      ),
    );
  }
}
