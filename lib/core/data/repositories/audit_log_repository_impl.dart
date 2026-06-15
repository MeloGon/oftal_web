import 'package:fpdart/fpdart.dart';
import 'package:oftal_web/core/data/datasources/remote/audit_log_remote_datasource.dart';
import 'package:oftal_web/core/domain/repositories/audit_log_repository.dart';
import 'package:oftal_web/core/errors/failures.dart';
import 'package:oftal_web/shared/models/audit_log_model.dart';

class AuditLogRepositoryImpl implements AuditLogRepository {
  AuditLogRepositoryImpl(this._dataSource);
  final AuditLogRemoteDataSource _dataSource;

  @override
  Future<Either<Failure, Unit>> log({
    required String action,
    required String entity,
    required String entityId,
    required String userEmail,
    required Map<String, dynamic> detail,
  }) async {
    try {
      await _dataSource.insert(
        action: action,
        entity: entity,
        entityId: entityId,
        userEmail: userEmail,
        detail: detail,
      );
      return const Right(unit);
    } catch (e) {
      return Left(Failure.server(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<AuditLogModel>>> getRecent({
    int limit = 5,
  }) async {
    try {
      final result = await _dataSource.getRecent(limit: limit);
      return Right(result);
    } catch (e) {
      return Left(Failure.server(e.toString()));
    }
  }

  @override
  Future<Either<Failure, ({List<AuditLogModel> items, bool hasMore})>> getAll({
    String? action,
    String? userEmail,
    DateTime? from,
    DateTime? to,
    int offset = 0,
    int limit = 20,
  }) async {
    try {
      final result = await _dataSource.getAll(
        action: action,
        userEmail: userEmail,
        from: from,
        to: to,
        offset: offset,
        limit: limit,
      );
      return Right(result);
    } catch (e) {
      return Left(Failure.server(e.toString()));
    }
  }
}
