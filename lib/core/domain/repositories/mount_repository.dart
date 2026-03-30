import 'package:fpdart/fpdart.dart';
import 'package:oftal_web/core/errors/failures.dart';
import 'package:oftal_web/shared/models/shared_models.dart';

abstract class MountRepository {
  Future<Either<Failure, List<MountModel>>> searchMounts(String query);
  Future<Either<Failure, ({List<MountModel> items, bool hasMore})>> fetchPage({
    required int offset,
    required int limit,
  });
  Future<Either<Failure, MountModel>> getMountById(int id);
  Future<Either<Failure, Unit>> insertMount(MountModel mount);
  Future<Either<Failure, Unit>> updateMount(MountModel mount);
  Future<Either<Failure, Unit>> deleteMount(int id);
  Future<Either<Failure, Unit>> decrementStock(int id, int currentStock);
}
