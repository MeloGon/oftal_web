import 'package:fpdart/fpdart.dart';
import 'package:oftal_web/core/data/datasources/remote/mount_remote_datasource.dart';
import 'package:oftal_web/core/domain/repositories/mount_repository.dart';
import 'package:oftal_web/core/errors/failures.dart';
import 'package:oftal_web/shared/models/shared_models.dart';

class MountRepositoryImpl implements MountRepository {
  final MountRemoteDataSource _dataSource;
  MountRepositoryImpl(this._dataSource);

  @override
  Future<Either<Failure, List<MountModel>>> searchMounts(String query) async {
    try {
      return Right(await _dataSource.searchMounts(query));
    } catch (e) {
      return Left(Failure.server(e.toString()));
    }
  }

  @override
  Future<Either<Failure, ({List<MountModel> items, bool hasMore})>> fetchPage({
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
  Future<Either<Failure, MountModel>> getMountById(int id) async {
    try {
      return Right(await _dataSource.getMountById(id));
    } catch (e) {
      return Left(Failure.server(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> insertMount(MountModel mount) async {
    try {
      await _dataSource.insertMount(mount);
      return const Right(unit);
    } catch (e) {
      return Left(Failure.server(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> updateMount(MountModel mount) async {
    try {
      await _dataSource.updateMount(mount);
      return const Right(unit);
    } catch (e) {
      return Left(Failure.server(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteMount(int id) async {
    try {
      await _dataSource.deleteMount(id);
      return const Right(unit);
    } catch (e) {
      return Left(Failure.server(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> decrementStock(
    int id,
    int currentStock,
  ) async {
    try {
      await _dataSource.decrementStock(id, currentStock);
      return const Right(unit);
    } catch (e) {
      return Left(Failure.server(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> incrementStock(int id) async {
    try {
      await _dataSource.incrementStock(id);
      return const Right(unit);
    } catch (e) {
      return Left(Failure.server(e.toString()));
    }
  }
}
