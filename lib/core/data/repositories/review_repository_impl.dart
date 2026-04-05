import 'package:fpdart/fpdart.dart';
import 'package:oftal_web/core/data/datasources/remote/review_remote_datasource.dart';
import 'package:oftal_web/core/domain/repositories/review_repository.dart';
import 'package:oftal_web/core/errors/failures.dart';
import 'package:oftal_web/shared/models/shared_models.dart';

class ReviewRepositoryImpl implements ReviewRepository {
  final ReviewRemoteDataSource _dataSource;
  ReviewRepositoryImpl(this._dataSource);

  @override
  Future<Either<Failure, List<ReviewModel>>> getReviewsByPatient(
    String patientName,
  ) async {
    try {
      return Right(await _dataSource.getReviewsByPatient(patientName));
    } catch (e) {
      return Left(Failure.server(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> insertReview(ReviewModel review) async {
    try {
      await _dataSource.insertReview(review);
      return const Right(unit);
    } catch (e) {
      return Left(Failure.server(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> updateReview(ReviewModel review) async {
    try {
      await _dataSource.updateReview(review);
      return const Right(unit);
    } catch (e) {
      return Left(Failure.server(e.toString()));
    }
  }
}
