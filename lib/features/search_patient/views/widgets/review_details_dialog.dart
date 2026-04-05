import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:oftal_web/features/search_patient/viewmodels/search_patient_state.dart';
import 'package:oftal_web/features/search_patient/views/widgets/edit_review_dialog.dart';
import 'package:oftal_web/shared/models/shared_models.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class ReviewDetailsDialog {
  Future<void> show(
    BuildContext context,
    SearchPatientState state,
    WidgetRef ref,
  ) async {
    final reviews = state.reviews;
    return showShadDialog(
      context: context,
      builder: (context) {
        final size = MediaQuery.sizeOf(context);
        return ShadDialog(
          constraints: BoxConstraints(
            maxWidth: size.width * 0.72,
            minWidth: 340,
            maxHeight: size.height * 0.85,
          ),
          title: Text(reviews.first.patientName ?? 'Paciente'),
          description: Text(
            reviews.length == 1
                ? '1 medición registrada'
                : '${reviews.length} mediciones registradas',
          ),
          actions: [
            ShadButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cerrar'),
            ),
          ],
          child: Flexible(
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                spacing: 12,
                children: reviews.asMap().entries.map((e) {
                  return _ReviewCard(
                    review: e.value,
                    index: e.key + 1,
                    total: reviews.length,
                    ref: ref,
                  );
                }).toList(),
              ),
            ),
          ),
        );
      },
    );
  }
}

// ─── Review card ─────────────────────────────────────────────────────────────

class _ReviewCard extends StatelessWidget {
  const _ReviewCard({
    required this.review,
    required this.index,
    required this.total,
    required this.ref,
  });

  final ReviewModel review;
  final int index;
  final int total;
  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    final hasRefraction = _anyOf([
      review.odEsf, review.oiEsf,
      review.odCil, review.oiCil,
      review.odEje, review.oiEje,
      review.odAv,  review.oiAv,
    ]);
    final hasLc = _anyOf([
      review.odCbLc, review.oiCbLc,
      review.odDiamLc, review.oiDiamLc,
    ]);
    final hasAvSinRx = _anyOf([
      review.avSinRxOdLejos, review.avSinRxOiLejos,
      review.avSinRxOdCerca, review.avSinRxOiCerca,
    ]);
    final hasAvConRx = _anyOf([
      review.avConRxOdCerca, review.avConRxOiCerca,
    ]);

    return ShadCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 14,
        children: [
          // ─ Header ──────────────────────────────────────────
          Row(
            children: [
              Expanded(
                child: Row(
                  spacing: 16,
                  children: [
                    _InfoChip(
                      icon: Icons.calendar_today_outlined,
                      label: review.date ?? 'Sin fecha',
                    ),
                    _InfoChip(
                      icon: Icons.store_outlined,
                      label: review.branchName ?? 'Sin sucursal',
                    ),
                  ],
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                spacing: 8,
                children: [
                  if (total > 1)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xffEEECFE),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '$index / $total',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Color(0xff7A6BF5),
                        ),
                      ),
                    ),
                  Tooltip(
                    message: 'Editar medición',
                    child: Material(
                      type: MaterialType.transparency,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(6),
                        onTap: () => EditReviewDialog().show(
                          context,
                          ref,
                          review,
                        ),
                        child: const Padding(
                          padding: EdgeInsets.all(4),
                          child: Icon(
                            Icons.edit_outlined,
                            size: 16,
                            color: Color(0xff0EA5E9),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),

          // ─ Motivo ──────────────────────────────────────────
          if (_has(review.reasonConsult))
            _FieldRow(
              label: 'Motivo de consulta',
              value: review.reasonConsult!,
            ),

          // ─ Graduación ──────────────────────────────────────
          if (_has(review.graduationType))
            _FieldRow(
              label: 'Tipo de graduación',
              value: review.graduationType!,
            ),

          // ─ Refracción ──────────────────────────────────────
          if (hasRefraction) ...[
            _SectionLabel('Refracción'),
            _MeasureGrid(rows: [
              if (_anyOf([review.odEsf, review.oiEsf]))
                _MRow('ESF', review.odEsf, review.oiEsf),
              if (_anyOf([review.odCil, review.oiCil]))
                _MRow('CIL', review.odCil, review.oiCil),
              if (_anyOf([review.odEje, review.oiEje]))
                _MRow('EJE', review.odEje, review.oiEje),
              if (_anyOf([review.odAv, review.oiAv]))
                _MRow('AV', review.odAv, review.oiAv),
            ]),
          ],

          // ─ Lentes de contacto ──────────────────────────────
          if (hasLc) ...[
            _SectionLabel('Lentes de contacto'),
            _MeasureGrid(rows: [
              if (_anyOf([review.odCbLc, review.oiCbLc]))
                _MRow('CB LC', review.odCbLc, review.oiCbLc),
              if (_anyOf([review.odDiamLc, review.oiDiamLc]))
                _MRow('DIAM LC', review.odDiamLc, review.oiDiamLc),
            ]),
          ],

          // ─ AV sin RX ───────────────────────────────────────
          if (hasAvSinRx) ...[
            _SectionLabel('AV sin RX'),
            _MeasureGrid(rows: [
              if (_anyOf([review.avSinRxOdLejos, review.avSinRxOiLejos]))
                _MRow('Lejos', review.avSinRxOdLejos, review.avSinRxOiLejos),
              if (_anyOf([review.avSinRxOdCerca, review.avSinRxOiCerca]))
                _MRow('Cerca', review.avSinRxOdCerca, review.avSinRxOiCerca),
            ]),
          ],

          // ─ AV con RX ───────────────────────────────────────
          if (hasAvConRx) ...[
            _SectionLabel('AV con RX'),
            _MeasureGrid(rows: [
              if (_anyOf([review.avConRxOdCerca, review.avConRxOiCerca]))
                _MRow('Cerca', review.avConRxOdCerca, review.avConRxOiCerca),
            ]),
          ],

          // ─ Otros valores ───────────────────────────────────
          if (_has(review.add) || _has(review.dip))
            Wrap(
              spacing: 24,
              runSpacing: 8,
              children: [
                if (_has(review.add))
                  _FieldRow(label: 'ADD', value: review.add!),
                if (_has(review.dip))
                  _FieldRow(label: 'DIP', value: review.dip!),
              ],
            ),

          // ─ Diagnóstico ─────────────────────────────────────
          if (_has(review.optometricDiagnosis))
            _FieldRow(
              label: 'Diagnóstico optométrico',
              value: review.optometricDiagnosis!,
            ),

          // ─ Observaciones ───────────────────────────────────
          if (_has(review.observation))
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xffFAFAFA),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xffE4E4E7)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 4,
                children: [
                  const Text(
                    'Observaciones',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Color(0xff71717A),
                    ),
                  ),
                  Text(
                    review.observation!,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xff18181B),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  bool _has(String? v) => v != null && v.isNotEmpty;
  bool _anyOf(List<String?> vals) => vals.any(_has);
}

// ─── Measure grid (field | OD | OI) ─────────────────────────────────────────

class _MRow {
  final String label;
  final String? od;
  final String? oi;
  const _MRow(this.label, this.od, this.oi);
}

class _MeasureGrid extends StatelessWidget {
  const _MeasureGrid({required this.rows});
  final List<_MRow> rows;

  @override
  Widget build(BuildContext context) {
    return Table(
      columnWidths: const {
        0: FlexColumnWidth(2),
        1: FlexColumnWidth(3),
        2: FlexColumnWidth(3),
      },
      children: [
        // Header row
        TableRow(
          decoration: const BoxDecoration(
            color: Color(0xffF4F4F5),
            borderRadius: BorderRadius.all(Radius.circular(6)),
          ),
          children: const [
            _TCell('', isHeader: true),
            _TCell('OD', isHeader: true),
            _TCell('OI', isHeader: true),
          ],
        ),
        ...rows.map(
          (r) => TableRow(
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Color(0xffF4F4F5)),
              ),
            ),
            children: [
              _TCell(r.label, isLabel: true),
              _TCell(r.od ?? '—'),
              _TCell(r.oi ?? '—'),
            ],
          ),
        ),
      ],
    );
  }
}

class _TCell extends StatelessWidget {
  const _TCell(this.text, {this.isHeader = false, this.isLabel = false});
  final String text;
  final bool isHeader;
  final bool isLabel;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          fontWeight:
              (isHeader || isLabel) ? FontWeight.w600 : FontWeight.normal,
          color: isHeader
              ? const Color(0xff71717A)
              : isLabel
              ? const Color(0xff3F3F46)
              : const Color(0xff18181B),
        ),
      ),
    );
  }
}

// ─── Helpers ─────────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: Color(0xff7A6BF5),
        letterSpacing: 0.5,
      ),
    );
  }
}

class _FieldRow extends StatelessWidget {
  const _FieldRow({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: 6,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$label:',
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Color(0xff52525B),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 12, color: Color(0xff18181B)),
          ),
        ),
      ],
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      spacing: 4,
      children: [
        Icon(icon, size: 13, color: const Color(0xff71717A)),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Color(0xff52525B),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
