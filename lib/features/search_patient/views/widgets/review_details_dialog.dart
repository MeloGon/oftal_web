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
            maxWidth: (size.width * 0.85).clamp(320, 640),
            maxHeight: size.height * 0.85,
          ),
          title: Row(
            spacing: 10,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: const Color(0xffEEECFE),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.person_outline_rounded,
                  size: 18,
                  color: Color(0xff7A6BF5),
                ),
              ),
              Expanded(
                child: Text(
                  reviews.first.patientName ?? 'Paciente',
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          description: Row(
            spacing: 6,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Color(0xff7A6BF5),
                  shape: BoxShape.circle,
                ),
              ),
              Text(
                reviews.length == 1
                    ? '1 medición registrada'
                    : '${reviews.length} mediciones registradas',
              ),
            ],
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

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xffE4E4E7)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ─ Card header ─────────────────────────────────────
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: const BoxDecoration(
              color: Color(0xffFAFAFA),
              borderRadius: BorderRadius.vertical(top: Radius.circular(11)),
              border: Border(
                bottom: BorderSide(color: Color(0xffE4E4E7)),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 6,
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
                  spacing: 6,
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
                        color: const Color(0xffEFF6FF),
                        borderRadius: BorderRadius.circular(6),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(6),
                          onTap: () => EditReviewDialog().show(
                            context,
                            ref,
                            review,
                          ),
                          child: const Padding(
                            padding: EdgeInsets.all(6),
                            child: Icon(
                              Icons.edit_outlined,
                              size: 14,
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
          ),

          // ─ Card body ───────────────────────────────────────
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 12,
              children: [
                // ─ Motivo ────────────────────────────────────
                if (_has(review.reasonConsult))
                  _FieldRow(
                    label: 'Motivo de consulta',
                    value: review.reasonConsult!,
                  ),

                // ─ Graduación ────────────────────────────────
                if (_has(review.graduationType))
                  _FieldRow(
                    label: 'Tipo de graduación',
                    value: review.graduationType!,
                  ),

                // ─ Refracción ────────────────────────────────
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

                // ─ Lentes de contacto ────────────────────────
                if (hasLc) ...[
                  _SectionLabel('Lentes de contacto'),
                  _MeasureGrid(rows: [
                    if (_anyOf([review.odCbLc, review.oiCbLc]))
                      _MRow('CB LC', review.odCbLc, review.oiCbLc),
                    if (_anyOf([review.odDiamLc, review.oiDiamLc]))
                      _MRow('DIAM LC', review.odDiamLc, review.oiDiamLc),
                  ]),
                ],

                // ─ AV sin RX ─────────────────────────────────
                if (hasAvSinRx) ...[
                  _SectionLabel('AV sin RX'),
                  _MeasureGrid(rows: [
                    if (_anyOf([review.avSinRxOdLejos, review.avSinRxOiLejos]))
                      _MRow('Lejos', review.avSinRxOdLejos, review.avSinRxOiLejos),
                    if (_anyOf([review.avSinRxOdCerca, review.avSinRxOiCerca]))
                      _MRow('Cerca', review.avSinRxOdCerca, review.avSinRxOiCerca),
                  ]),
                ],

                // ─ AV con RX ─────────────────────────────────
                if (hasAvConRx) ...[
                  _SectionLabel('AV con RX'),
                  _MeasureGrid(rows: [
                    if (_anyOf([review.avConRxOdCerca, review.avConRxOiCerca]))
                      _MRow('Cerca', review.avConRxOdCerca, review.avConRxOiCerca),
                  ]),
                ],

                // ─ ADD / DIP ─────────────────────────────────
                if (_has(review.add) || _has(review.dip))
                  Wrap(
                    spacing: 12,
                    runSpacing: 8,
                    children: [
                      if (_has(review.add))
                        _ValueBadge(label: 'ADD', value: review.add!),
                      if (_has(review.dip))
                        _ValueBadge(label: 'DIP', value: review.dip!),
                    ],
                  ),

                // ─ Diagnóstico ───────────────────────────────
                if (_has(review.optometricDiagnosis))
                  _FieldRow(
                    label: 'Diagnóstico optométrico',
                    value: review.optometricDiagnosis!,
                  ),

                // ─ Observaciones ─────────────────────────────
                if (_has(review.observation))
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xffFAFAFA),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xffE4E4E7)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: 4,
                      children: [
                        Row(
                          spacing: 6,
                          children: const [
                            Icon(
                              Icons.notes_rounded,
                              size: 13,
                              color: Color(0xff71717A),
                            ),
                            Text(
                              'Observaciones',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: Color(0xff71717A),
                              ),
                            ),
                          ],
                        ),
                        Text(
                          review.observation!,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xff18181B),
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
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xffE4E4E7)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Table(
        columnWidths: const {
          0: FlexColumnWidth(2),
          1: FlexColumnWidth(3),
          2: FlexColumnWidth(3),
        },
        children: [
          // Header row
          const TableRow(
            decoration: BoxDecoration(color: Color(0xffF4F4F5)),
            children: [
              _TCell('', isHeader: true),
              _TCell('OD', isHeader: true),
              _TCell('OI', isHeader: true),
            ],
          ),
          ...rows.asMap().entries.map(
            (e) => TableRow(
              decoration: BoxDecoration(
                color: e.key.isEven ? Colors.white : const Color(0xffFAFAFA),
              ),
              children: [
                _TCell(e.value.label, isLabel: true),
                _TCell(e.value.od ?? '—'),
                _TCell(e.value.oi ?? '—'),
              ],
            ),
          ),
        ],
      ),
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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
    return Row(
      spacing: 8,
      children: [
        Container(
          width: 3,
          height: 14,
          decoration: BoxDecoration(
            color: const Color(0xff7A6BF5),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        Text(
          text,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: Color(0xff7A6BF5),
            letterSpacing: 0.3,
          ),
        ),
      ],
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xffF4F4F5),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: 5,
        children: [
          Icon(icon, size: 12, color: const Color(0xff71717A)),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xff52525B),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _ValueBadge extends StatelessWidget {
  const _ValueBadge({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xffF4F4F5),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xffE4E4E7)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: 6,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: Color(0xff71717A),
            ),
          ),
          Container(
            width: 1,
            height: 12,
            color: const Color(0xffD4D4D8),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xff18181B),
            ),
          ),
        ],
      ),
    );
  }
}
