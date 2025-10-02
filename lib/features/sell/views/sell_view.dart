import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:oftal_web/core/constants/constants.dart';
import 'package:oftal_web/features/sell/viewmodels/sell_provider.dart';
import 'package:oftal_web/features/sell/viewmodels/sell_state.dart';
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
                    'Se encontraron ${next.reviews.length} mediciones',
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
      child: ShadCard(
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
                          'Se encontraron (${sellState.patients.length}) resultados',
                        ),
                      ),
                      SliverList.separated(
                        separatorBuilder: (context, index) => const Divider(),
                        itemBuilder: (context, index) {
                          return ListTile(
                            title: Text(sellState.patients[index].name),
                            subtitle: Row(
                              spacing: 10,
                              children: [
                                Text(AppStrings.registerDate),
                                Text(sellState.patients[index].registerDate),
                              ],
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              spacing: 10,
                              children: [
                                ShadIconButton(
                                  icon: Icon(LucideIcons.shoppingBasket300),
                                  onPressed: () {},
                                ),
                                ShadIconButton(
                                  icon: Icon(LucideIcons.eye300),
                                  onPressed: () async {
                                    sellNotifier.selectPatient(
                                      sellState.patients[index],
                                    );
                                    await sellNotifier.getViewMeasurements();
                                  },
                                ),
                                ShadIconButton(
                                  icon: Icon(LucideIcons.trash2300),
                                  onPressed: () {},
                                ),
                              ],
                            ),
                          );
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
    ).marginOnly(top: 50).paddingSymmetric(horizontal: 20);
  }
}
