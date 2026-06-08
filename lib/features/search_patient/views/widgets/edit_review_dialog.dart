import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:oftal_web/core/theme/app_colors.dart';
import 'package:oftal_web/features/search_patient/viewmodels/search_patient_provider.dart';
import 'package:oftal_web/shared/models/shared_models.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class EditReviewDialog {
  Future<void> show(
    BuildContext context,
    WidgetRef ref,
    ReviewModel review,
  ) async {
    return showShadDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => _EditReviewContent(review: review, ref: ref),
    );
  }
}

class _EditReviewContent extends StatefulWidget {
  const _EditReviewContent({required this.review, required this.ref});
  final ReviewModel review;
  final WidgetRef ref;

  @override
  State<_EditReviewContent> createState() => _EditReviewContentState();
}

class _EditReviewContentState extends State<_EditReviewContent> {
  // ── Refracción ──────────────────────────────────────────────
  late final TextEditingController _odEsfCtrl;
  late final TextEditingController _odCilCtrl;
  late final TextEditingController _odEjeCtrl;
  late final TextEditingController _odAvCtrl;
  late final TextEditingController _oiEsfCtrl;
  late final TextEditingController _oiCilCtrl;
  late final TextEditingController _oiEjeCtrl;
  late final TextEditingController _oiAvCtrl;
  // ── LC ───────────────────────────────────────────────────────
  late final TextEditingController _odCbLcCtrl;
  late final TextEditingController _odDiamLcCtrl;
  late final TextEditingController _oiCbLcCtrl;
  late final TextEditingController _oiDiamLcCtrl;
  // ── AV sin/con RX ────────────────────────────────────────────
  late final TextEditingController _avSinRxOdLejosCtrl;
  late final TextEditingController _avSinRxOiLejosCtrl;
  late final TextEditingController _avSinRxOdCercaCtrl;
  late final TextEditingController _avSinRxOiCercaCtrl;
  late final TextEditingController _avConRxOdCercaCtrl;
  late final TextEditingController _avConRxOiCercaCtrl;
  // ── Otros ────────────────────────────────────────────────────
  late final TextEditingController _addCtrl;
  late final TextEditingController _dipCtrl;
  late final TextEditingController _graduationTypeCtrl;
  late final TextEditingController _reasonConsultCtrl;
  late final TextEditingController _clinicHistoryCtrl;
  late final TextEditingController _observationCtrl;
  late final TextEditingController _optometricDiagnosisCtrl;

  @override
  void initState() {
    super.initState();
    final r = widget.review;
    _odEsfCtrl = TextEditingController(text: r.odEsf ?? '');
    _odCilCtrl = TextEditingController(text: r.odCil ?? '');
    _odEjeCtrl = TextEditingController(text: r.odEje ?? '');
    _odAvCtrl = TextEditingController(text: r.odAv ?? '');
    _oiEsfCtrl = TextEditingController(text: r.oiEsf ?? '');
    _oiCilCtrl = TextEditingController(text: r.oiCil ?? '');
    _oiEjeCtrl = TextEditingController(text: r.oiEje ?? '');
    _oiAvCtrl = TextEditingController(text: r.oiAv ?? '');
    _odCbLcCtrl = TextEditingController(text: r.odCbLc ?? '');
    _odDiamLcCtrl = TextEditingController(text: r.odDiamLc ?? '');
    _oiCbLcCtrl = TextEditingController(text: r.oiCbLc ?? '');
    _oiDiamLcCtrl = TextEditingController(text: r.oiDiamLc ?? '');
    _avSinRxOdLejosCtrl = TextEditingController(text: r.avSinRxOdLejos ?? '');
    _avSinRxOiLejosCtrl = TextEditingController(text: r.avSinRxOiLejos ?? '');
    _avSinRxOdCercaCtrl = TextEditingController(text: r.avSinRxOdCerca ?? '');
    _avSinRxOiCercaCtrl = TextEditingController(text: r.avSinRxOiCerca ?? '');
    _avConRxOdCercaCtrl = TextEditingController(text: r.avConRxOdCerca ?? '');
    _avConRxOiCercaCtrl = TextEditingController(text: r.avConRxOiCerca ?? '');
    _addCtrl = TextEditingController(text: r.add ?? '');
    _dipCtrl = TextEditingController(text: r.dip ?? '');
    _graduationTypeCtrl =
        TextEditingController(text: r.graduationType ?? '');
    _reasonConsultCtrl =
        TextEditingController(text: r.reasonConsult ?? '');
    _clinicHistoryCtrl =
        TextEditingController(text: r.clinicHistory ?? '');
    _observationCtrl = TextEditingController(text: r.observation ?? '');
    _optometricDiagnosisCtrl =
        TextEditingController(text: r.optometricDiagnosis ?? '');
  }

  @override
  void dispose() {
    for (final c in [
      _odEsfCtrl, _odCilCtrl, _odEjeCtrl, _odAvCtrl,
      _oiEsfCtrl, _oiCilCtrl, _oiEjeCtrl, _oiAvCtrl,
      _odCbLcCtrl, _odDiamLcCtrl, _oiCbLcCtrl, _oiDiamLcCtrl,
      _avSinRxOdLejosCtrl, _avSinRxOiLejosCtrl,
      _avSinRxOdCercaCtrl, _avSinRxOiCercaCtrl,
      _avConRxOdCercaCtrl, _avConRxOiCercaCtrl,
      _addCtrl, _dipCtrl, _graduationTypeCtrl,
      _reasonConsultCtrl, _clinicHistoryCtrl,
      _observationCtrl, _optometricDiagnosisCtrl,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  void _save() {
    final updated = widget.review.copyWith(
      odEsf: _odEsfCtrl.text,
      odCil: _odCilCtrl.text,
      odEje: _odEjeCtrl.text,
      odAv: _odAvCtrl.text,
      oiEsf: _oiEsfCtrl.text,
      oiCil: _oiCilCtrl.text,
      oiEje: _oiEjeCtrl.text,
      oiAv: _oiAvCtrl.text,
      odCbLc: _odCbLcCtrl.text,
      odDiamLc: _odDiamLcCtrl.text,
      oiCbLc: _oiCbLcCtrl.text,
      oiDiamLc: _oiDiamLcCtrl.text,
      avSinRxOdLejos: _avSinRxOdLejosCtrl.text,
      avSinRxOiLejos: _avSinRxOiLejosCtrl.text,
      avSinRxOdCerca: _avSinRxOdCercaCtrl.text,
      avSinRxOiCerca: _avSinRxOiCercaCtrl.text,
      avConRxOdCerca: _avConRxOdCercaCtrl.text,
      avConRxOiCerca: _avConRxOiCercaCtrl.text,
      add: _addCtrl.text,
      dip: _dipCtrl.text,
      graduationType: _graduationTypeCtrl.text,
      reasonConsult: _reasonConsultCtrl.text,
      clinicHistory: _clinicHistoryCtrl.text,
      observation: _observationCtrl.text,
      optometricDiagnosis: _optometricDiagnosisCtrl.text,
    );
    Navigator.of(context).pop();
    widget.ref.read(searchPatientProvider.notifier).updateReview(updated);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return ShadDialog(
      constraints: BoxConstraints(
        maxWidth: (size.width * 0.85).clamp(320, 600),
        maxHeight: size.height * 0.88,
      ),
      title: Text(
        'Editar medición — ${widget.review.patientName ?? ''}',
      ),
      description: Text(
        'Fecha: ${widget.review.date ?? 'N/A'} · Sucursal: ${widget.review.branchName ?? 'N/A'}',
      ),
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
      child: Flexible(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            spacing: 20,
            children: [
              // ── Consulta ─────────────────────────────────
              _Section(
                label: 'Consulta',
                child: Column(
                  spacing: 12,
                  children: [
                    _Field('Motivo de consulta', _reasonConsultCtrl),
                    _Field('Historia clínica', _clinicHistoryCtrl),
                    _Field('Tipo de graduación', _graduationTypeCtrl),
                  ],
                ),
              ),

              // ── Refracción ───────────────────────────────
              _Section(
                label: 'Refracción',
                child: _MeasureFormGrid(rows: [
                  _FormRow('ESF', _odEsfCtrl, _oiEsfCtrl),
                  _FormRow('CIL', _odCilCtrl, _oiCilCtrl),
                  _FormRow('EJE', _odEjeCtrl, _oiEjeCtrl),
                  _FormRow('AV', _odAvCtrl, _oiAvCtrl),
                ]),
              ),

              // ── Lentes de contacto ───────────────────────
              _Section(
                label: 'Lentes de contacto',
                child: _MeasureFormGrid(rows: [
                  _FormRow('CB LC', _odCbLcCtrl, _oiCbLcCtrl),
                  _FormRow('DIAM LC', _odDiamLcCtrl, _oiDiamLcCtrl),
                ]),
              ),

              // ── AV sin RX ────────────────────────────────
              _Section(
                label: 'AV sin RX',
                child: _MeasureFormGrid(rows: [
                  _FormRow('Lejos', _avSinRxOdLejosCtrl, _avSinRxOiLejosCtrl),
                  _FormRow('Cerca', _avSinRxOdCercaCtrl, _avSinRxOiCercaCtrl),
                ]),
              ),

              // ── AV con RX ────────────────────────────────
              _Section(
                label: 'AV con RX',
                child: _MeasureFormGrid(rows: [
                  _FormRow('Cerca', _avConRxOdCercaCtrl, _avConRxOiCercaCtrl),
                ]),
              ),

              // ── Otros ────────────────────────────────────
              _Section(
                label: 'Otros',
                child: Column(
                  spacing: 12,
                  children: [
                    Row(
                      spacing: 12,
                      children: [
                        Expanded(child: _Field('ADD', _addCtrl)),
                        Expanded(child: _Field('DIP', _dipCtrl)),
                      ],
                    ),
                    _Field(
                      'Diagnóstico optométrico',
                      _optometricDiagnosisCtrl,
                    ),
                    _Field(
                      'Observaciones',
                      _observationCtrl,
                      maxLines: 3,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Section wrapper ─────────────────────────────────────────────────────────

class _Section extends StatelessWidget {
  const _Section({required this.label, required this.child});
  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 10,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: AppColors.primary,
            letterSpacing: 0.5,
          ),
        ),
        const Divider(height: 1),
        child,
      ],
    );
  }
}

// ─── Single text field ───────────────────────────────────────────────────────

class _Field extends StatelessWidget {
  const _Field(this.label, this.controller, {this.maxLines = 1});
  final String label;
  final TextEditingController controller;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return ShadInputFormField(
      label: Text(label),
      controller: controller,
      maxLines: maxLines,
      keyboardType:
          maxLines > 1 ? TextInputType.multiline : TextInputType.text,
    );
  }
}

// ─── OD / OI grid form ───────────────────────────────────────────────────────

class _FormRow {
  final String label;
  final TextEditingController od;
  final TextEditingController oi;
  const _FormRow(this.label, this.od, this.oi);
}

class _MeasureFormGrid extends StatelessWidget {
  const _MeasureFormGrid({required this.rows});
  final List<_FormRow> rows;

  @override
  Widget build(BuildContext context) {
    return Table(
      columnWidths: const {
        0: FlexColumnWidth(2),
        1: FlexColumnWidth(3),
        2: FlexColumnWidth(3),
      },
      children: [
        // Header
        const TableRow(
          decoration: BoxDecoration(
            color: AppColors.zinc100,
            borderRadius: BorderRadius.all(Radius.circular(6)),
          ),
          children: [
            _TH(''),
            _TH('OD'),
            _TH('OI'),
          ],
        ),
        ...rows.map(
          (r) => TableRow(
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: AppColors.zinc100),
              ),
            ),
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                child: Text(
                  r.label,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.zinc700,
                  ),
                ),
              ),
              _GridInput(r.od),
              _GridInput(r.oi),
            ],
          ),
        ),
      ],
    );
  }
}

class _TH extends StatelessWidget {
  const _TH(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: AppColors.zinc500,
        ),
      ),
    );
  }
}

class _GridInput extends StatelessWidget {
  const _GridInput(this.controller);
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      child: ShadInput(
        controller: controller,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      ),
    );
  }
}
