import 'package:flutter/material.dart';
import 'package:oftal_web/core/theme/app_colors.dart';
import 'package:oftal_web/features/sell/views/widgets/info_pill.dart';
import 'package:oftal_web/shared/models/shared_models.dart';

class PatientResultList extends StatelessWidget {
  const PatientResultList({
    super.key,
    required this.patients,
    required this.onSelect,
  });

  final List<PatientModel> patients;
  final ValueChanged<PatientModel> onSelect;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 8,
      children: [
        Text(
          '${patients.length} resultado${patients.length == 1 ? '' : 's'}',
          style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
        ),
        ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 300),
          child: ListView.separated(
            shrinkWrap: true,
            itemCount: patients.length,
            separatorBuilder: (_, __) => const SizedBox(height: 6),
            itemBuilder:
                (context, i) => PatientCard(
                  patient: patients[i],
                  onSelect: () => onSelect(patients[i]),
                ),
          ),
        ),
      ],
    );
  }
}

class PatientCard extends StatefulWidget {
  const PatientCard({
    super.key,
    required this.patient,
    required this.onSelect,
  });
  final PatientModel patient;
  final VoidCallback onSelect;

  @override
  State<PatientCard> createState() => PatientCardState();
}

class PatientCardState extends State<PatientCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final p = widget.patient;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onSelect,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: _hovered ? AppColors.violetBgLight : Colors.white,
            border: Border.all(
              color:
                  _hovered ? AppColors.primary : AppColors.zinc200,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: const BoxDecoration(
                  color: AppColors.primaryBg,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    p.name.isNotEmpty ? p.name[0].toUpperCase() : '?',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 3,
                  children: [
                    Text(
                      p.name,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.zinc900,
                      ),
                    ),
                    Row(
                      spacing: 12,
                      children: [
                        if (p.branch.isNotEmpty)
                          InfoPill(
                            icon: Icons.store_outlined,
                            label: p.branch,
                          ),
                        if (p.phone.isNotEmpty)
                          InfoPill(
                            icon: Icons.phone_outlined,
                            label: p.phone,
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                spacing: 4,
                children: [
                  Text(
                    p.registerDate,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.zinc500,
                    ),
                  ),
                  AnimatedOpacity(
                    opacity: _hovered ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 120),
                    child: const Text(
                      'Seleccionar →',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
