import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class PatientFormHeader extends StatelessWidget {
  const PatientFormHeader({
    super.key,
    required this.onCancel,
    required this.onSave,
    required this.isLoading,
  });

  final VoidCallback onCancel;
  final VoidCallback onSave;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 560;

        final titleBlock = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 4,
          children: [
            const Text(
              'Nuevo paciente',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: Color(0xff18181B),
              ),
            ),
            Text(
              'Registra un paciente en la red Oftal Web',
              style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
            ),
          ],
        );

        final actionButtons = Row(
          mainAxisAlignment:
              isNarrow ? MainAxisAlignment.end : MainAxisAlignment.start,
          spacing: 12,
          children: [
            ShadButton.outline(
              size: ShadButtonSize.lg,
              onPressed: onCancel,
              child: const Text('Cancelar'),
            ),
            ShadButton(
              size: ShadButtonSize.lg,
              onPressed: isLoading ? null : onSave,
              child: isLoading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Row(
                      mainAxisSize: MainAxisSize.min,
                      spacing: 6,
                      children: [
                        Icon(Icons.check_rounded, size: 16),
                        Text('Guardar paciente'),
                      ],
                    ),
            ),
          ],
        );

        if (isNarrow) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 12,
            children: [titleBlock, actionButtons],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(child: titleBlock),
            actionButtons,
          ],
        );
      },
    );
  }
}
