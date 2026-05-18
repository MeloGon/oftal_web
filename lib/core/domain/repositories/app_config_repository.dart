import 'package:fpdart/fpdart.dart';
import 'package:oftal_web/core/errors/failures.dart';

abstract class AppConfigRepository {
  Future<Either<Failure, Map<String, String>>> getAll();
  Future<Either<Failure, Unit>> setValue(String key, String value);
}
