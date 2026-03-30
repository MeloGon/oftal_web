import 'package:fpdart/fpdart.dart';
import 'package:oftal_web/core/data/datasources/remote/patient_remote_datasource.dart';
import 'package:oftal_web/core/domain/repositories/patient_repository.dart';
import 'package:oftal_web/core/errors/failures.dart';
import 'package:oftal_web/shared/models/shared_models.dart';

class PatientRepositoryImpl implements PatientRepository {
  final PatientRemoteDataSource _dataSource;
  PatientRepositoryImpl(this._dataSource);

  @override
  Future<Either<Failure, List<PatientModel>>> searchPatients(
    String query,
  ) async {
    try {
      return Right(await _dataSource.searchPatients(query));
    } catch (e) {
      return Left(Failure.server(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<PatientModel>>> getLastPatients({
    int limit = 5,
  }) async {
    try {
      return Right(await _dataSource.getLastPatients(limit: limit));
    } catch (e) {
      return Left(Failure.server(e.toString()));
    }
  }

  @override
  Future<Either<Failure, int>> countByBranch(String branch) async {
    try {
      return Right(await _dataSource.countByBranch(branch));
    } catch (e) {
      return Left(Failure.server(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> insertPatient(PatientModel patient) async {
    try {
      await _dataSource.insertPatient(patient);
      return const Right(unit);
    } catch (e) {
      return Left(Failure.server(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> deletePatient(int id) async {
    try {
      await _dataSource.deletePatient(id);
      return const Right(unit);
    } catch (e) {
      return Left(Failure.server(e.toString()));
    }
  }
}
