import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class CardStatisticItem extends StatelessWidget {
  const CardStatisticItem({
    super.key,
    required this.title,
    required this.content,
  });
  final String title;
  final String content;

  @override
  Widget build(BuildContext context) {
    return ShadCard(
      child: Column(
        children: [
          Text(title),
          Text(content),
        ],
      ),
    );
  }
}
