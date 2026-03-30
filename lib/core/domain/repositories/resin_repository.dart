import 'package:fpdart/fpdart.dart';
import 'package:oftal_web/core/errors/failures.dart';
import 'package:oftal_web/shared/models/shared_models.dart';

abstract class ResinRepository {
  Future<Either<Failure, List<ResinModel>>> searchResins(String query);
  Future<Either<Failure, ({List<ResinModel> items, bool hasMore})>> fetchPage({
    required int offset,
    required int limit,
  });
  Future<Either<Failure, Unit>> insertResin(ResinModel resin);
  Future<Either<Failure, Unit>> updateResin(ResinModel resin);
  Future<Either<Failure, Unit>> deleteResin(int id);
}
