import 'package:flutter/material.dart';
import 'package:oftal_web/features/search_patient/viewmodels/search_patient_state.dart';
import 'package:oftal_web/features/search_patient/views/widgets/label_reviews_item.dart';
import 'package:oftal_web/shared/extensions/extensions.dart';
import 'package:oftal_web/shared/models/shared_models.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class ReviewDetailsDialog {
  Future<void> show(BuildContext context, SearchPatientState state) async {
    return showShadDialog(
      context: context,
      builder:
          (context) => ShadDialog(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.sizeOf(context).width * .6,
              minWidth: 293,
            ),
            title: Text(
              'Datos del paciente: ${state.reviews.first.patientName ?? 'N/A'}',
            ),
            description: Text(
              '${state.reviews.length} mediciones encontradas, escrollea para ver las mediciones',
            ),
            actions: [
              ShadButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('Cerrar'),
              ),
            ],
            child: ReviewsDialog(state: state, reviews: state.reviews),
          ),
    );
  }
}

class ReviewsDialog extends StatelessWidget {
  final SearchPatientState state;
  final List<ReviewModel> reviews;

  const ReviewsDialog({super.key, required this.state, required this.reviews});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Column(
        spacing: 8,
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children:
            state.reviews
                .map(
                  (review) => ShadCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: 2,
                      children: [
                        Text(
                          'Fecha: ${review.date ?? 'N/A'} | Sucursal: ${review.branchName ?? 'N/A'}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (review.reasonConsult != null &&
                                    review.reasonConsult!.isNotEmpty)
                                  LabelReviewsItem(
                                    title: 'Motivo',
                                    subtitle: review.reasonConsult,
                                  ),
                                if (review.odEsf != null &&
                                    review.odEsf!.isNotEmpty)
                                  LabelReviewsItem(
                                    title: 'OD ESF',
                                    subtitle: review.odEsf,
                                  ),
                                if (review.oiEsf != null &&
                                    review.oiEsf!.isNotEmpty)
                                  LabelReviewsItem(
                                    title: 'OI ESF',
                                    subtitle: review.oiEsf,
                                  ),
                                if (review.odCil != null &&
                                    review.odCil!.isNotEmpty)
                                  LabelReviewsItem(
                                    title: 'OD CIL',
                                    subtitle: review.odCil,
                                  ),
                                if (review.oiCil != null &&
                                    review.oiCil!.isNotEmpty)
                                  LabelReviewsItem(
                                    title: 'OI CIL',
                                    subtitle: review.oiCil,
                                  ),
                                if (review.odEje != null &&
                                    review.odEje!.isNotEmpty)
                                  LabelReviewsItem(
                                    title: 'OD EJE',
                                    subtitle: review.odEje,
                                  ),
                                if (review.oiEje != null &&
                                    review.oiEje!.isNotEmpty)
                                  LabelReviewsItem(
                                    title: 'OI EJE',
                                    subtitle: review.oiEje,
                                  ),
                                if (review.odAv != null &&
                                    review.odAv!.isNotEmpty)
                                  LabelReviewsItem(
                                    title: 'OD AV',
                                    subtitle: review.odAv,
                                  ),
                                if (review.oiAv != null &&
                                    review.oiAv!.isNotEmpty)
                                  LabelReviewsItem(
                                    title: 'OI AV',
                                    subtitle: review.oiAv,
                                  ),
                                if (review.add != null &&
                                    review.add!.isNotEmpty)
                                  LabelReviewsItem(
                                    title: 'ADD',
                                    subtitle: review.add,
                                  ),
                                if (review.observation != null &&
                                    review.observation!.isNotEmpty)
                                  LabelReviewsItem(
                                    title: 'Observaciones',
                                    subtitle: review.observation,
                                  ),
                                if (review.dip != null &&
                                    review.dip!.isNotEmpty)
                                  LabelReviewsItem(
                                    title: 'DIP',
                                    subtitle: review.dip,
                                  ),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (review.odCbLc != null &&
                                    review.odCbLc!.isNotEmpty)
                                  LabelReviewsItem(
                                    title: 'OD CB LC',
                                    subtitle: review.odCbLc,
                                  ),
                                if (review.odDiamLc != null &&
                                    review.odDiamLc!.isNotEmpty)
                                  LabelReviewsItem(
                                    title: 'OD DIAM LC',
                                    subtitle: review.odDiamLc,
                                  ),
                                if (review.oiCbLc != null &&
                                    review.oiCbLc!.isNotEmpty)
                                  LabelReviewsItem(
                                    title: 'OI CB LC',
                                    subtitle: review.oiCbLc,
                                  ),
                                if (review.oiDiamLc != null &&
                                    review.oiDiamLc!.isNotEmpty)
                                  LabelReviewsItem(
                                    title: 'OI DIAM LC',
                                    subtitle: review.oiDiamLc,
                                  ),
                                if (review.graduationType != null &&
                                    review.graduationType!.isNotEmpty)
                                  LabelReviewsItem(
                                    title: 'Tipo de graduacion',
                                    subtitle: review.graduationType,
                                  ),
                                if (review.avSinRxOdLejos != null &&
                                    review.avSinRxOdLejos!.isNotEmpty)
                                  LabelReviewsItem(
                                    title: 'AV SIN RX OD LEJOS',
                                    subtitle: review.avSinRxOdLejos,
                                  ),
                                if (review.avSinRxOiLejos != null &&
                                    review.avSinRxOiLejos!.isNotEmpty)
                                  LabelReviewsItem(
                                    title: 'AV SIN RX OI LEJOS',
                                    subtitle: review.avSinRxOiLejos,
                                  ),
                                if (review.avSinRxOdCerca != null &&
                                    review.avSinRxOdCerca!.isNotEmpty)
                                  LabelReviewsItem(
                                    title: 'AV SIN RX OD CERCA',
                                    subtitle: review.avSinRxOdCerca,
                                  ),
                                if (review.avSinRxOiCerca != null &&
                                    review.avSinRxOiCerca!.isNotEmpty)
                                  LabelReviewsItem(
                                    title: 'AV SIN RX OI CERCA',
                                    subtitle: review.avSinRxOiCerca,
                                  ),
                                if (review.avConRxOdCerca != null &&
                                    review.avConRxOdCerca!.isNotEmpty)
                                  LabelReviewsItem(
                                    title: 'AV CON RX OD CERCA',
                                    subtitle: review.avConRxOdCerca,
                                  ),
                                if (review.avConRxOiCerca != null &&
                                    review.avConRxOiCerca!.isNotEmpty)
                                  LabelReviewsItem(
                                    title: 'AV CON RX OI CERCA',
                                    subtitle: review.avConRxOiCerca,
                                  ),
                                if (review.optometricDiagnosis != null &&
                                    review.optometricDiagnosis!.isNotEmpty)
                                  LabelReviewsItem(
                                    title: 'Diagnostico optometrico',
                                    subtitle: review.optometricDiagnosis,
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ).padding(all: 12),
                  ),
                )
                .toList(),
      ),
    );
  }
}
