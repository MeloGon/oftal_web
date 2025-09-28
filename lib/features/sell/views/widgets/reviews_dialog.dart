import 'package:flutter/material.dart';
import 'package:oftal_web/features/sell/viewmodels/sell_state.dart';
import 'package:oftal_web/features/sell/views/widgets/label_reviews_item.dart';
import 'package:oftal_web/shared/extensions/extensions.dart';
import 'package:oftal_web/shared/models/review_model.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class ReviewsDialog extends StatelessWidget {
  final SellState state;
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
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                LabelReviewsItem(
                                  title: 'Motivo',
                                  subtitle: review.reasonConsult,
                                ),
                                LabelReviewsItem(
                                  title: 'OD ESF',
                                  subtitle: review.odEsf,
                                ),
                                LabelReviewsItem(
                                  title: 'OI ESF',
                                  subtitle: review.oiEsf,
                                ),
                                LabelReviewsItem(
                                  title: 'OD CIL',
                                  subtitle: review.odCil,
                                ),
                                LabelReviewsItem(
                                  title: 'OI CIL',
                                  subtitle: review.oiCil,
                                ),
                                LabelReviewsItem(
                                  title: 'OD EJE',
                                  subtitle: review.odEje,
                                ),
                                LabelReviewsItem(
                                  title: 'OI EJE',
                                  subtitle: review.oiEje,
                                ),
                                LabelReviewsItem(
                                  title: 'OD AV',
                                  subtitle: review.odAv,
                                ),
                                LabelReviewsItem(
                                  title: 'OI AV',
                                  subtitle: review.oiAv,
                                ),
                                LabelReviewsItem(
                                  title: 'ADD',
                                  subtitle: review.add,
                                ),
                                LabelReviewsItem(
                                  title: 'Observaciones',
                                  subtitle: review.observation,
                                ),
                                LabelReviewsItem(
                                  title: 'DIP',
                                  subtitle: review.dip,
                                ),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                LabelReviewsItem(
                                  title: 'OD CB LC',
                                  subtitle: review.odCbLc,
                                ),
                                LabelReviewsItem(
                                  title: 'OD DIAM LC',
                                  subtitle: review.odDiamLc,
                                ),
                                LabelReviewsItem(
                                  title: 'OI CB LC',
                                  subtitle: review.oiCbLc,
                                ),
                                LabelReviewsItem(
                                  title: 'OI DIAM LC',
                                  subtitle: review.oiDiamLc,
                                ),
                                LabelReviewsItem(
                                  title: 'Tipo de graduacion',
                                  subtitle: review.graduationType,
                                ),
                                LabelReviewsItem(
                                  title: 'AV SIN RX OD LEJOS',
                                  subtitle: review.avSinRxOdLejos,
                                ),
                                LabelReviewsItem(
                                  title: 'AV SIN RX OI LEJOS',
                                  subtitle: review.avSinRxOiLejos,
                                ),
                                LabelReviewsItem(
                                  title: 'AV SIN RX OD CERCA',
                                  subtitle: review.avSinRxOdCerca,
                                ),
                                LabelReviewsItem(
                                  title: 'AV SIN RX OI CERCA',
                                  subtitle: review.avSinRxOiCerca,
                                ),
                                LabelReviewsItem(
                                  title: 'AV CON RX OD CERCA',
                                  subtitle: review.avConRxOdCerca,
                                ),
                                LabelReviewsItem(
                                  title: 'AV CON RX OI CERCA',
                                  subtitle: review.avConRxOiCerca,
                                ),
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
