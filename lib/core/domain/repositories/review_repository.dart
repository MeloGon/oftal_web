import 'package:fpdart/fpdart.dart';
import 'package:oftal_web/core/errors/failures.dart';
import 'package:oftal_web/shared/models/shared_models.dart';

abstract class ReviewRepository {
  Future<Either<Failure, List<ReviewModel>>> getReviewsByPatient(
    String patientName,
  );
  Future<Either<Failure, Unit>> insertReview(ReviewModel review);
  Future<Either<Failure, Unit>> updateReview(ReviewModel review);
}
