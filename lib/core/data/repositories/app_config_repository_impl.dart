import 'package:fpdart/fpdart.dart';
import 'package:oftal_web/core/data/datasources/remote/app_config_remote_datasource.dart';
import 'package:oftal_web/core/domain/repositories/app_config_repository.dart';
import 'package:oftal_web/core/errors/failures.dart';

class AppConfigRepositoryImpl implements AppConfigRepository {
  AppConfigRepositoryImpl(this._dataSource);
  final AppConfigRemoteDataSource _dataSource;

  @override
  Future<Either<Failure, Map<String, String>>> getAll() async {
    try {
      final result = await _dataSource.getAll();
      return Right(result);
    } catch (e) {
      return Left(Failure.server(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> setValue(String key, String value) async {
    try {
      await _dataSource.setValue(key, value);
      return const Right(unit);
    } catch (e) {
      return Left(Failure.server(e.toString()));
    }
  }
}
