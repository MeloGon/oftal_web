import 'package:flutter/material.dart';
import 'package:oftal_web/core/theme/app_colors.dart';

class Logo extends StatelessWidget {
  const Logo({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: 30),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.bubble_chart_outlined, color: AppColors.primary),
          SizedBox(width: 10),
          Text('OFTALWEB', style: TextStyle(color: Colors.white, fontSize: 20)),
        ],
      ),
    );
  }
}
