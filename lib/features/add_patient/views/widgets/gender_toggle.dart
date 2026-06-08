import 'package:flutter/material.dart';
import 'package:oftal_web/core/theme/app_colors.dart';

class GenderToggle extends StatelessWidget {
  const GenderToggle({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final String? value;
  final ValueChanged<String> onChanged;

  static const _options = ['Femenino', 'Masculino', 'Otro'];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 6,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          spacing: 2,
          children: [
            Text(
              'Género',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: value == null
                    ? Colors.red.shade600
                    : AppColors.zinc700,
              ),
            ),
            Text(
              ' *',
              style: TextStyle(fontSize: 13, color: Colors.red.shade600),
            ),
          ],
        ),
        Container(
          height: 40,
          decoration: BoxDecoration(
            border: Border.all(
              color: value == null
                  ? Colors.red.shade400
                  : AppColors.zinc200,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(7),
            child: Row(
              children: List.generate(_options.length, (i) {
                final opt = _options[i];
                final selected = value == opt;
                final isLast = i == _options.length - 1;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => onChanged(opt),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      height: 40,
                      decoration: BoxDecoration(
                        color: selected
                            ? AppColors.zinc900
                            : Colors.transparent,
                        border: !isLast
                            ? const Border(
                                right: BorderSide(color: AppColors.zinc200),
                              )
                            : null,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        opt,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: selected
                              ? Colors.white
                              : AppColors.zinc700,
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
        if (value == null)
          Text(
            'Campo requerido',
            style: TextStyle(fontSize: 11, color: Colors.red.shade600),
          ),
      ],
    );
  }
}
