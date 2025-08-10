import 'package:flutter/material.dart';
import 'package:oftal_web/core/constants/app_strings.dart';

class NoPageFoundView extends StatelessWidget {
  const NoPageFoundView({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: Center(
        child: Text(AppStrings.pageNotFound),
      ),
    );
  }
}
