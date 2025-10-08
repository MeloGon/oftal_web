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
      child: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: 15,
        children: [
          Container(
            width: 2,
            height: 100,
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          Column(
            children: [
              Text(title, style: ShadTheme.of(context).textTheme.h3),
              Text(content, style: ShadTheme.of(context).textTheme.h2),
            ],
          ),
        ],
      ),
    );
  }
}
