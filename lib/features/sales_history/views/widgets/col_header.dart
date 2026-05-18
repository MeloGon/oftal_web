import 'package:flutter/material.dart';

class ColHeader extends StatelessWidget {
  const ColHeader(this.text, {super.key});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: Color(0xff52525B),
      ),
    );
  }
}
