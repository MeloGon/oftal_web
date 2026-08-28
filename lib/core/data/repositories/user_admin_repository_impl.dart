import 'package:fpdart/fpdart.dart';
import 'package:oftal_web/core/data/datasources/remote/user_admin_remote_datasource.dart';
import 'package:oftal_web/core/domain/repositories/user_admin_repository.dart';
import 'package:oftal_web/core/errors/failures.dart';
import 'package:oftal_web/shared/models/profile_model.dart';

class UserAdminRepositoryImpl implements UserAdminRepository {
  final UserAdminRemoteDataSource _dataSource;
  UserAdminRepositoryImpl(this._dataSource);

  @override
  Future<Either<Failure, List<ProfileModel>>> listUsers() async {
    try {
      return Right(await _dataSource.listUsers());
    } catch (e) {
      return Left(Failure.server(functionErrorMessage(e)));
    }
  }

  @override
  Future<Either<Failure, Unit>> resetPassword({
    required String userId,
    required String newPassword,
  }) async {
    try {
      await _dataSource.resetPassword(
        userId: userId,
        newPassword: newPassword,
      );
      return const Right(unit);
    } catch (e) {
      return Left(Failure.server(functionErrorMessage(e)));
    }
  }
}
