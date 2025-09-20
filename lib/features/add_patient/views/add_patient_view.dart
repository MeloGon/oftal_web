import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:oftal_web/features/add_patient/views/widgets/add_patient_desk.dart';
import 'package:oftal_web/features/add_patient/views/widgets/add_patient_mob.dart';
import 'package:oftal_web/features/add_patient/views/widgets/add_patient_tabl.dart';
import 'package:oftal_web/shared/extensions/extensions.dart';
import 'package:oftal_web/shared/widgets/widgets.dart';

class AddPatientView extends StatelessWidget {
  const AddPatientView({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Responsive(
          mobile: const AddPatientMobile(),
          tablet: const AddPatientTablet(),
          desktop: const AddPatientDesktop(),
        ),
      ],
    ).marginOnly(top: 50).paddingSymmetric(horizontal: 20);
  }
}
