import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:oftal_web/core/constants/constants.dart';
import 'package:oftal_web/features/sell/viewmodels/sell_provider.dart';
import 'package:oftal_web/shared/extensions/extensions.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class SellView extends ConsumerWidget {
  const SellView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sellNotifier = ref.watch(sellProvider.notifier);
    final sellState = ref.watch(sellProvider);
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
                backgroundColor: Colors.blueGrey[50],
                child: Scrollbar(
                  thumbVisibility: true,
                  child: CustomScrollView(
                    primary: true,
                    slivers: [
                      SliverList(
                        delegate: SliverChildBuilderDelegate((context, index) {
                          if (index.isOdd) return const Divider();
                          return ListTile(
                            title: Text(sellState.patients[index].name),
                          );
                        }, childCount: sellState.patients.length),
                      ),
                    ],
                  ),
                ),
              ).paddingOnly(top: 20),
            if (sellState.patients.isEmpty && !sellState.isLoading)
              ShadCard(
                height: 70,
                backgroundColor: Colors.blueGrey[100],
                child: const Center(
                  child: Text(
                    'No se encontraron pacientes o no se ha realizado la búsqueda',
                  ),
                ),
              ).paddingOnly(top: 20),
          ],
        ),
      ),
    ).marginOnly(top: 50).paddingSymmetric(horizontal: 20);
  }
}
