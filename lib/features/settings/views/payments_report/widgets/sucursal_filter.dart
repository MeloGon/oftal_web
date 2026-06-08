import 'package:flutter/material.dart';
import 'package:oftal_web/core/theme/app_colors.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class SucursalFilter extends StatelessWidget {
  const SucursalFilter({
    super.key,
    required this.sucursales,
    required this.selected,
    required this.onChanged,
  });

  static const _all = '';

  final List<String> sucursales;
  final String? selected;
  final void Function(String?) onChanged;

  @override
  Widget build(BuildContext context) {
    return ShadSelect<String>(
      placeholder: const Row(
        mainAxisSize: MainAxisSize.min,
        spacing: 6,
        children: [
          Icon(Icons.store_outlined, size: 14, color: AppColors.zinc500),
          Text('Todas las sucursales'),
        ],
      ),
      selectedOptionBuilder:
          (context, value) => Row(
            mainAxisSize: MainAxisSize.min,
            spacing: 6,
            children: [
              const Icon(
                Icons.store_outlined,
                size: 14,
                color: AppColors.zinc900,
              ),
              Text(value.isEmpty ? 'Todas las sucursales' : value),
            ],
          ),
      initialValue: selected ?? _all,
      onChanged: (v) => onChanged(v == null || v.isEmpty ? null : v),
      options: [
        const ShadOption(value: _all, child: Text('Todas las sucursales')),
        ...sucursales.map((s) => ShadOption(value: s, child: Text(s))),
      ],
    );
  }
}
