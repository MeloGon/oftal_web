import 'package:fpdart/fpdart.dart';
import 'package:oftal_web/core/errors/failures.dart';
import 'package:oftal_web/shared/models/shared_models.dart';

abstract class PatientRepository {
  Future<Either<Failure, List<PatientModel>>> searchPatients(String query);
  Future<Either<Failure, List<PatientModel>>> getLastPatients({int limit = 5});
  Future<Either<Failure, int>> countByBranch(String branch);
  Future<Either<Failure, Unit>> insertPatient(PatientModel patient);
  Future<Either<Failure, Unit>> deletePatient(int id);
}
