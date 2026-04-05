import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:oftal_web/shared/models/shared_models.dart';

abstract class ReviewRemoteDataSource {
  Future<List<ReviewModel>> getReviewsByPatient(String patientName);
  Future<void> insertReview(ReviewModel review);
  Future<void> updateReview(ReviewModel review);
}

class ReviewRemoteDataSourceImpl implements ReviewRemoteDataSource {
  final SupabaseClient client;
  ReviewRemoteDataSourceImpl(this.client);

  @override
  Future<List<ReviewModel>> getReviewsByPatient(String patientName) async {
    final response = await client
        .from('revisiones')
        .select()
        .ilike('"PACIENTE"', '%$patientName%');
    return response.map((json) => ReviewModel.fromJson(json)).toList();
  }

  @override
  Future<void> insertReview(ReviewModel review) async {
    await client.from('revisiones').insert(review.toJson());
  }

  @override
  Future<void> updateReview(ReviewModel review) async {
    await client.from('revisiones').update({
      'MOTIVO DE CONSULTA': review.reasonConsult,
      'HISTORIA CLINICA': review.clinicHistory,
      'OD ESF': review.odEsf,
      'OD CIL': review.odCil,
      'OD EJE': review.odEje,
      'OD AV': review.odAv,
      'OI ESF': review.oiEsf,
      'OI CIL': review.oiCil,
      'OI EJE': review.oiEje,
      'OI AV': review.oiAv,
      'ADD': review.add,
      'OBSERVACIONES': review.observation,
      'DIP': review.dip,
      'OD CB LC': review.odCbLc,
      'OD DIAM LC': review.odDiamLc,
      'OI CB LC': review.oiCbLc,
      'OI DIAM LC': review.oiDiamLc,
      'TIPO DE GRADUACION': review.graduationType,
      'AV SIN RX OD LEJOS': review.avSinRxOdLejos,
      'AV SIN RX OI LEJOS': review.avSinRxOiLejos,
      'AV SIN RX OD CERCA': review.avSinRxOdCerca,
      'AV SIN RX OI CERCA': review.avSinRxOiCerca,
      'AV CON RX OD CERCA': review.avConRxOdCerca,
      'AV CON RX OI CERCA': review.avConRxOiCerca,
      'DIAGNOSTICO OPTOMETRICO': review.optometricDiagnosis,
    }).eq('ID REFRACCION', review.idReview);
  }
}
