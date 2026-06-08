import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:oftal_web/core/theme/app_colors.dart';
import 'package:oftal_web/core/enums/enums.dart';
import 'package:oftal_web/features/search_patient/viewmodels/search_patient_provider.dart';
import 'package:oftal_web/shared/models/shared_models.dart';
import 'package:oftal_web/shared/widgets/widgets.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class EditPatientDialog {
  Future<void> show(
    BuildContext context,
    WidgetRef ref,
    PatientModel patient,
  ) async {
    return showShadDialog(
      context: context,
      builder: (context) => _EditPatientDialogContent(
        patient: patient,
        ref: ref,
      ),
    );
  }
}

class _EditPatientDialogContent extends StatefulWidget {
  const _EditPatientDialogContent({
    required this.patient,
    required this.ref,
  });

  final PatientModel patient;
  final WidgetRef ref;

  @override
  State<_EditPatientDialogContent> createState() =>
      _EditPatientDialogContentState();
}

class _EditPatientDialogContentState extends State<_EditPatientDialogContent> {
  final _formKey = GlobalKey<ShadFormState>();

  late final TextEditingController _nameCtrl;
  late final TextEditingController _phoneCtrl;
  late final TextEditingController _birthDateCtrl;
  late final TextEditingController _observationsCtrl;
  late DateTime _selectedBirthDate;

  String? _selectedGender;
  String? _selectedBranch;

  static final _dateFmt = DateFormat('dd-MM-yyyy');

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.patient.name);
    _phoneCtrl = TextEditingController(text: widget.patient.phone);
    try {
      _selectedBirthDate = _dateFmt.parse(widget.patient.birthDate);
    } catch (_) {
      _selectedBirthDate = DateTime.now();
    }
    _birthDateCtrl = TextEditingController(text: widget.patient.birthDate);
    _observationsCtrl =
        TextEditingController(text: widget.patient.observations);
    _selectedGender = widget.patient.gender.isNotEmpty
        ? widget.patient.gender
        : null;
    _selectedBranch = widget.patient.branch.isNotEmpty
        ? widget.patient.branch
        : null;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _birthDateCtrl.dispose();
    _observationsCtrl.dispose();
    super.dispose();
  }

  void _save() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (_selectedGender == null || _selectedBranch == null) {
      setState(() {});
      return;
    }

    final updated = widget.patient.copyWith(
      name: _nameCtrl.text.trim(),
      phone: _phoneCtrl.text.trim(),
      birthDate: _birthDateCtrl.text.trim(),
      observations: _observationsCtrl.text.trim(),
      gender: _selectedGender!,
      branch: _selectedBranch!,
    );

    Navigator.of(context).pop();
    widget.ref.read(searchPatientProvider.notifier).updatePatient(updated);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    return ShadDialog(
      constraints: BoxConstraints(
        maxWidth: (size.width * 0.85).clamp(320, 580),
      ),
      title: const Text('Editar paciente'),
      description: Text(widget.patient.name),
      actions: [
        ShadButton.outline(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        ShadButton(
          onPressed: _save,
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            spacing: 6,
            children: [
              Icon(Icons.save_outlined, size: 15),
              Text('Guardar cambios'),
            ],
          ),
        ),
      ],
      child: ShadForm(
        key: _formKey,
        autovalidateMode: ShadAutovalidateMode.onUserInteraction,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          spacing: 16,
          children: [
            // ─ Nombre | Teléfono ───────────────────────────
            Row(
              spacing: 12,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: ShadInputFormField(
                    label: const Text('Apellidos y Nombres'),
                    controller: _nameCtrl,
                    validator: (v) =>
                        v.trim().isEmpty ? 'Campo requerido' : null,
                  ),
                ),
                SizedBox(
                  width: 150,
                  child: ShadInputFormField(
                    label: const Text('Teléfono'),
                    controller: _phoneCtrl,
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),

            // ─ Género | Fecha nacimiento | Sucursal ────────
            Row(
              spacing: 12,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 160,
                  child: _LabeledField(
                    label: 'Género',
                    required: true,
                    hasError: _selectedGender == null,
                    child: ShadSelect<String>(
                      placeholder: const Text('Seleccione'),
                      initialValue: _selectedGender,
                      selectedOptionBuilder: (_, v) => Text(v),
                      options: const ['Masculino', 'Femenino', 'Otro']
                          .map((e) => ShadOption(value: e, child: Text(e)))
                          .toList(),
                      onChanged: (v) => setState(() => _selectedGender = v),
                    ),
                  ),
                ),
                AppDatePickerButton(
                  label: 'Fecha de nacimiento',
                  selectedDate: _selectedBirthDate,
                  lastDate: DateTime.now(),
                  onDateSelected: (date) {
                    setState(() {
                      _selectedBirthDate = date;
                      _birthDateCtrl.text = _dateFmt.format(date);
                    });
                  },
                ),
                Expanded(
                  child: _LabeledField(
                    label: 'Sucursal',
                    required: true,
                    hasError: _selectedBranch == null,
                    child: ShadSelect<BranchEnum>(
                      placeholder: const Text('Seleccione'),
                      initialValue: _selectedBranch != null
                          ? BranchEnum.values.firstWhere(
                              (e) => e.name == _selectedBranch,
                              orElse: () => BranchEnum.values.first,
                            )
                          : null,
                      selectedOptionBuilder: (_, v) => Text(v.name),
                      options: BranchEnum.values
                          .map(
                            (e) => ShadOption(value: e, child: Text(e.name)),
                          )
                          .toList(),
                      onChanged: (v) =>
                          setState(() => _selectedBranch = v?.name),
                    ),
                  ),
                ),
              ],
            ),

            // ─ Observaciones ───────────────────────────────
            ShadInputFormField(
              label: const Text('Observaciones'),
              controller: _observationsCtrl,
              maxLines: 3,
              keyboardType: TextInputType.multiline,
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Helper: labeled field wrapper for ShadSelect ────────────────────────────

class _LabeledField extends StatelessWidget {
  const _LabeledField({
    required this.label,
    required this.child,
    this.required = false,
    this.hasError = false,
  });

  final String label;
  final Widget child;
  final bool required;
  final bool hasError;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 6,
      children: [
        Row(
          spacing: 2,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: hasError
                    ? Colors.red.shade600
                    : AppColors.zinc700,
              ),
            ),
            if (required)
              Text(
                ' *',
                style: TextStyle(fontSize: 13, color: Colors.red.shade600),
              ),
          ],
        ),
        child,
        if (hasError)
          Text(
            'Campo requerido',
            style: TextStyle(fontSize: 11, color: Colors.red.shade600),
          ),
      ],
    );
  }
}
