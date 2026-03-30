import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:oftal_web/shared/models/shared_models.dart';

abstract class ReviewRemoteDataSource {
  Future<List<ReviewModel>> getReviewsByPatient(String patientName);
  Future<void> insertReview(ReviewModel review);
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
}
