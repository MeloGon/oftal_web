import 'package:flutter/material.dart';
import 'package:oftal_web/shared/extensions/extensions.dart';

class SectionLabel extends StatelessWidget {
  const SectionLabel({
    super.key,
    required this.label,
    required this.total,
    required this.color,
    required this.icon,
  });
  final String label;
  final double total;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: 10,
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 16, color: color),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
        const Spacer(),
        Text(
          total.toCurrency(),
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
      ],
    );
  }
}

class SubSectionLabel extends StatelessWidget {
  const SubSectionLabel({
    super.key,
    required this.label,
    required this.total,
    required this.color,
  });
  final String label;
  final double total;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: 8,
      children: [
        Container(
          width: 3,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
        const Spacer(),
        Text(
          total.toCurrency(),
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }
}
