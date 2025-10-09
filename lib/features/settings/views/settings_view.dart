import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:oftal_web/core/enums/enums.dart';
import 'package:oftal_web/features/settings/viewmodels/settings_provider.dart';
import 'package:oftal_web/shared/extensions/extensions.dart';
import 'package:oftal_web/shared/models/shared_models.dart';
import 'package:oftal_web/shared/widgets/widgets.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class SettingsView extends ConsumerWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // final settingsState = ref.watch(settingsProvider);
    final settingsNotifier = ref.watch(settingsProvider.notifier);

    ref.listen(settingsProvider, (previous, next) {
      if (next.errorMessage.isNotEmpty &&
          previous?.errorMessage != next.errorMessage) {
        _showSnackbar(context, next.snackbarConfig, next.errorMessage);
        Future.microtask(
          () => ref.read(settingsProvider.notifier).clearErrorMessage(),
        );
      }
    });
    return ShadCard(
      width: MediaQuery.sizeOf(context).width * .9,
      child: Column(
        children: [
          ShadAccordion<int>(
            children: [
              ShadAccordionItem(
                value: 1,
                title: Text(
                  'Añadir resina',
                  style: ShadTheme.of(context).textTheme.h4,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 8,
                  children: [
                    ShadInputFormField(
                      label: Text('Descripción'),
                      controller: settingsNotifier.descriptionController,
                    ),
                    Row(
                      spacing: 20,
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        ShadInputFormField(
                          label: Text('Diseño'),
                          controller: settingsNotifier.designController,
                        ).box(width: MediaQuery.sizeOf(context).width * .35),
                        ShadInputFormField(
                          label: Text('Linea'),
                          controller: settingsNotifier.lineController,
                        ).box(width: MediaQuery.sizeOf(context).width * .35),
                      ],
                    ).box(width: MediaQuery.sizeOf(context).width * .9),
                    Row(
                      spacing: 20,
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        ShadInputFormField(
                          label: Text('Material'),
                          controller: settingsNotifier.materialController,
                        ).box(width: MediaQuery.sizeOf(context).width * .35),
                        ShadInputFormField(
                          label: Text('Tecnología'),
                          controller: settingsNotifier.technologyController,
                        ).box(width: MediaQuery.sizeOf(context).width * .35),
                      ],
                    ).box(width: MediaQuery.sizeOf(context).width * .9),
                    Wrap(
                      direction: Axis.horizontal,
                      spacing: 20,
                      runSpacing: 10,
                      children: [
                        ShadInputFormField(
                          label: Text('Precio'),
                          controller: settingsNotifier.priceController,
                        ).box(width: 100),
                        ShadInputFormField(
                          label: Text('Cantidad'),
                          controller: settingsNotifier.quantityController,
                        ).box(width: 100),
                      ],
                    ),
                    Row(
                      spacing: 10,
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        ShadButton(
                          width: 100,
                          onPressed:
                              ref.read(settingsProvider.notifier).addResin,
                          child: Text('Añadir'),
                        ).expanded(),
                        ShadButton.outline(
                          width: 100,
                          onPressed:
                              ref
                                  .read(settingsProvider.notifier)
                                  .clearAddResinForm,
                          child: Text('Cancelar'),
                        ).expanded(),
                      ],
                    ).paddingOnly(top: 10),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    ).paddingSymmetric(horizontal: 20, vertical: 10);
  }
}

void _showSnackbar(
  BuildContext context,
  SnackbarConfigModel? snackbarConfig,
  String errorMessage,
) {
  CustomSnackbar().show(
    context,
    snackbarConfig ??
        SnackbarConfigModel(title: 'Error', type: SnackbarEnum.error),
    errorMessage,
  );
}
