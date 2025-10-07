import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:oftal_web/core/constants/constants.dart';
import 'package:oftal_web/core/enums/enums.dart';
import 'package:oftal_web/features/sell/viewmodels/sell_provider.dart';
import 'package:oftal_web/features/sell/viewmodels/sell_state.dart';
import 'package:oftal_web/features/sell/views/widgets/item_to_add_cart.dart';
import 'package:oftal_web/features/sell/views/widgets/item_to_sell.dart';
import 'package:oftal_web/features/sell/views/widgets/reviews_dialog.dart';
import 'package:oftal_web/shared/extensions/extensions.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class SellView extends ConsumerWidget {
  const SellView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sellNotifier = ref.watch(sellProvider.notifier);
    final sellState = ref.watch(sellProvider);

    ref.listen<SellState>(sellProvider, (previous, next) {
      if (next.reviews.isNotEmpty && previous?.reviews != next.reviews) {
        if (context.mounted) {
          showShadDialog(
            context: context,
            builder:
                (context) => ShadDialog(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.sizeOf(context).width * .6,
                    minWidth: 293,
                  ),
                  title: Text(
                    'Datos del paciente: ${next.selectedPatient?.name ?? 'N/A'}',
                  ),
                  description: Text(
                    'Se encontraron ${next.reviews.length} mediciones, escrollea para ver las mediciones',
                  ),
                  actions: [
                    ShadButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text('Cerrar'),
                    ),
                  ],
                  child: ReviewsDialog(state: next, reviews: next.reviews),
                ),
          );
        }
      }
    });

    return SizedBox(
      child: Column(
        spacing: 20,
        children: [
          ShadCard(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Vender',
                  style: ShadTheme.of(context).textTheme.h2,
                ).alignment(Alignment.centerLeft).paddingOnly(bottom: 20),
                ShadInput(
                  placeholder: Text('Ingrese el nombre del paciente'),
                  leading: Icon(LucideIcons.search),
                  controller: sellNotifier.searchController,
                  trailing: ShadButton(
                    height: 30,
                    onPressed: () => sellNotifier.searchPatient(),
                    child: Text(
                      AppStrings.search,
                    ),
                  ),
                  onSubmitted: (_) => sellNotifier.searchPatient(),
                ),
                if (sellState.isLoading)
                  const Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                    ),
                  ).paddingOnly(top: 20),
                if (sellState.patients.isNotEmpty && !sellState.isLoading)
                  ShadCard(
                    height: 300,
                    child: Scrollbar(
                      thumbVisibility: true,
                      child: CustomScrollView(
                        primary: true,
                        slivers: [
                          SliverToBoxAdapter(
                            child: Text(
                              'Se encontraron (${sellState.patients.length}) resultados, escrollea para ver los pacientes',
                            ),
                          ),
                          SliverList.separated(
                            separatorBuilder:
                                (context, index) => const Divider(),
                            itemBuilder: (context, index) {
                              final patient = sellState.patients[index];
                              return ItemToSell(patient: patient);
                            },
                            itemCount: sellState.patients.length,
                          ),
                        ],
                      ),
                    ),
                  ).paddingOnly(top: 20),
                if (sellState.patients.isEmpty && !sellState.isLoading)
                  ShadCard(
                    height: 70,
                    child: const Center(
                      child: Text(
                        AppStrings.noPatientsFound,
                      ),
                    ),
                  ).paddingOnly(top: 20),
              ],
            ),
          ),
          ShadCard(
            width: MediaQuery.sizeOf(context).width * .9,
            child: Column(
              spacing: 20,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Seleccione los productos a vender',
                  style: ShadTheme.of(context).textTheme.h2,
                ),
                Wrap(
                  spacing: 16,
                  runSpacing: 8,
                  direction: Axis.horizontal,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: 8,
                      children: [
                        Text('Clasificación'),
                        ShadSelect<String>(
                          placeholder: Text(AppStrings.select),
                          // initialValue: addPatientState.selectedGender,
                          selectedOptionBuilder:
                              (context, value) => Text(value),
                          options:
                              OptionsToSellEnum.values
                                  .map(
                                    (e) => ShadOption(
                                      value: e.name,
                                      child: Text(e.name),
                                    ),
                                  )
                                  .toList(),
                          onChanged: (value) {
                            // addPatientNotifier.updateGender(value);
                          },
                          // controller: addPatientNotifier.genderController,
                        ),
                      ],
                    ),
                    ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: MediaQuery.sizeOf(context).width * .6,
                      ),
                      child: Column(
                        children: [
                          ShadInputFormField(
                            placeholder: Text('Ingrese'),
                            label: Text('Nombre del producto'),
                            controller: sellNotifier.searchItemToSellController,
                            onSubmitted: (_) => sellNotifier.getMounts(),
                          ),
                          if (sellState.mounts.isNotEmpty &&
                              !sellState.isLoading)
                            ShadCard(
                              height: 300,
                              child: Scrollbar(
                                thumbVisibility: true,
                                child: CustomScrollView(
                                  primary: true,
                                  slivers: [
                                    SliverToBoxAdapter(
                                      child: Text(
                                        'Se encontraron (${sellState.mounts.length}) lineas',
                                      ),
                                    ),
                                    SliverList.separated(
                                      separatorBuilder:
                                          (context, index) => const Divider(),
                                      itemBuilder: (context, index) {
                                        final mount = sellState.mounts[index];
                                        return ItemToAddCart(mount: mount);
                                      },
                                      itemCount: sellState.mounts.length,
                                    ),
                                  ],
                                ),
                              ),
                            ).paddingOnly(top: 20),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          ShadCard(
            width: MediaQuery.sizeOf(context).width * .9,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Nota de venta',
                  style: ShadTheme.of(context).textTheme.h2,
                ),
                ShadCard(
                  // child: ,
                ),
              ],
            ),
          ),
        ],
      ),
    ).marginOnly(top: 50).paddingSymmetric(horizontal: 20);
  }
}
