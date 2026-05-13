import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:oftal_web/features/add_patient/viewmodels/add_patient_provider.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class PatientSummarySidebar extends ConsumerWidget {
  const PatientSummarySidebar({super.key});

  static String _getInitials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '•';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(addPatientProvider.notifier);
    final state = ref.watch(addPatientProvider);

    return AnimatedBuilder(
      animation: Listenable.merge([
        notifier.nameController,
        notifier.phoneController,
      ]),
      builder: (context, _) {
        final name = notifier.nameController.text.trim();
        final initials = _getInitials(name);
        final branch = state.selectedBranch ?? 'Central';
        final phone = notifier.phoneController.text.trim();

        return Column(
          spacing: 16,
          children: [
            ShadCard(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 16,
                children: [
                  // Header
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 2,
                    children: [
                      Row(
                        spacing: 8,
                        children: const [
                          Icon(
                            Icons.preview_outlined,
                            size: 16,
                            color: Color(0xff7A6BF5),
                          ),
                          Text(
                            'Resumen',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Color(0xff18181B),
                            ),
                          ),
                        ],
                      ),
                      const Padding(
                        padding: EdgeInsets.only(left: 24),
                        child: Text(
                          'Vista previa del registro',
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xff9CA3AF),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 1),

                  // Avatar + name
                  Row(
                    spacing: 12,
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0xff7A6BF5),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          initials,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          spacing: 2,
                          children: [
                            Text(
                              name.isEmpty ? 'Sin nombre' : name,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: Color(0xff18181B),
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              'Sin DNI · $branch',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xff71717A),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 1),

                  _SummaryRow(
                    label: 'Teléfono',
                    value: phone.isEmpty ? '—' : phone,
                  ),
                ],
              ),
            ),

            // Privacidad card
            ShadCard(
              padding: const EdgeInsets.all(20),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 12,
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xffEEF2FF),
                      border: Border.all(color: const Color(0xffC7D2FE)),
                    ),
                    alignment: Alignment.center,
                    child: const Icon(
                      Icons.info_outline_rounded,
                      size: 16,
                      color: Color(0xff6366F1),
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: 4,
                      children: [
                        const Text(
                          'Privacidad',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Color(0xff18181B),
                          ),
                        ),
                        Text(
                          'Los datos se almacenan cifrados y solo personal autorizado puede acceder al historial clínico.',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade500,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 13, color: Color(0xff52525B)),
        ),
        Text(
          value,
          style: const TextStyle(fontSize: 13, color: Color(0xff18181B)),
        ),
      ],
    );
  }
}
