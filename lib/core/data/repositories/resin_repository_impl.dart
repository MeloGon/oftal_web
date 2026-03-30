import 'package:fpdart/fpdart.dart';
import 'package:oftal_web/core/data/datasources/remote/resin_remote_datasource.dart';
import 'package:oftal_web/core/domain/repositories/resin_repository.dart';
import 'package:oftal_web/core/errors/failures.dart';
import 'package:oftal_web/shared/models/shared_models.dart';

class ResinRepositoryImpl implements ResinRepository {
  final ResinRemoteDataSource _dataSource;
  ResinRepositoryImpl(this._dataSource);

  @override
  Future<Either<Failure, List<ResinModel>>> searchResins(String query) async {
    try {
      return Right(await _dataSource.searchResins(query));
    } catch (e) {
      return Left(Failure.server(e.toString()));
    }
  }

  @override
  Future<Either<Failure, ({List<ResinModel> items, bool hasMore})>> fetchPage({
    required int offset,
    required int limit,
  }) async {
    try {
      return Right(
        await _dataSource.fetchPage(offset: offset, limit: limit),
      );
    } catch (e) {
      return Left(Failure.server(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> insertResin(ResinModel resin) async {
    try {
      await _dataSource.insertResin(resin);
      return const Right(unit);
    } catch (e) {
      return Left(Failure.server(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> updateResin(ResinModel resin) async {
    try {
      await _dataSource.updateResin(resin);
      return const Right(unit);
    } catch (e) {
      return Left(Failure.server(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteResin(int id) async {
    try {
      await _dataSource.deleteResin(id);
      return const Right(unit);
    } catch (e) {
      return Left(Failure.server(e.toString()));
    }
  }
}
