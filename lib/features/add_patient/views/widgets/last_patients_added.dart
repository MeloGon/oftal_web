import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:oftal_web/core/constants/app_strings.dart';
import 'package:oftal_web/core/enums/enums.dart';
import 'package:oftal_web/core/theme/app_text_styles.dart';
import 'package:oftal_web/features/add_patient/viewmodels/add_patient_provider.dart';
import 'package:oftal_web/features/sell/viewmodels/sell_provider.dart';
import 'package:oftal_web/router/app_router.dart';
import 'package:oftal_web/router/router_name.dart';
import 'package:oftal_web/shared/extensions/extensions.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class LastPatientsAdded extends ConsumerWidget {
  const LastPatientsAdded({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final width = MediaQuery.sizeOf(context).width;
    final lastPatients = ref.watch(
      addPatientProvider.select((u) => u.lastPatients),
    );
    return ShadCard(
      width: width * .9,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 10,
        children: [
          Text(
            AppStrings.lastPatients,
            style: AppTextStyles(context).small14Bold,
          ),
          ListView.separated(
            physics: const NeverScrollableScrollPhysics(),
            itemCount: lastPatients.length,
            shrinkWrap: true,
            separatorBuilder: (context, index) => const Divider(),
            itemBuilder: (context, index) {
              final patient = lastPatients[index];
              return SizedBox(
                height: 35,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      patient.name,
                      style: AppTextStyles(context).small12,
                    ),
                    ShadButton(
                      onPressed: () {
                        ref
                            .read(sellProvider.notifier)
                            .selectPatientAndOption(
                              patient,
                              SellItemOptionsEnum.sell,
                            );
                        ref.read(appRouterProvider).go(RouterName.sell);
                      },
                      child: Text('Ir a vender'),
                    ),
                  ],
                ).paddingSymmetric(vertical: 2),
              );
            },
          ),
        ],
      ),
    );
  }
}
