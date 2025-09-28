import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:oftal_web/shared/extensions/extensions.dart';

class LabelReviewsItem extends StatelessWidget {
  final String? title;
  final String? subtitle;
  const LabelReviewsItem({super.key, this.title, this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          '$title: ',
          style: ShadTheme.of(
            context,
          ).textTheme.small.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          subtitle.orNA,
        ),
      ],
    );
  }
}
