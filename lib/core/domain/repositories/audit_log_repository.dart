import 'package:fpdart/fpdart.dart';
import 'package:oftal_web/core/errors/failures.dart';
import 'package:oftal_web/shared/models/audit_log_model.dart';

abstract class AuditLogRepository {
  Future<Either<Failure, Unit>> log({
    required String action,
    required String entity,
    required String entityId,
    required String userEmail,
    required Map<String, dynamic> detail,
  });

  Future<Either<Failure, List<AuditLogModel>>> getRecent({int limit = 5});

  Future<Either<Failure, List<AuditLogModel>>> getAll({
    String? action,
    String? userEmail,
    DateTime? from,
    DateTime? to,
  });
}
