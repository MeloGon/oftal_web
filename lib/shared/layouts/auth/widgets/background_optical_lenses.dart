import 'package:flutter/material.dart';
import 'package:oftal_web/core/constants/app_images.dart';

class BackgroundOpticalLenses extends StatelessWidget {
  const BackgroundOpticalLenses({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: double.infinity,
      constraints: BoxConstraints(maxWidth: 400),
      child: Image.asset(
        AppImages.backgroundOpticalLenses,
        fit: BoxFit.cover,
      ),
    );
  }
}
