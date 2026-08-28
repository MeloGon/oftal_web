import 'package:fpdart/fpdart.dart';
import 'package:oftal_web/core/errors/failures.dart';
import 'package:oftal_web/shared/models/profile_model.dart';

abstract class UserAdminRepository {
  Future<Either<Failure, List<ProfileModel>>> listUsers();
  Future<Either<Failure, Unit>> resetPassword({
    required String userId,
    required String newPassword,
  });
}
