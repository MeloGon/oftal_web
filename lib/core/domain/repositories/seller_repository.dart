import 'package:fpdart/fpdart.dart';
import 'package:oftal_web/core/errors/failures.dart';
import 'package:oftal_web/shared/models/shared_models.dart';

abstract class SellerRepository {
  Future<Either<Failure, List<SellerModel>>> getSellers();
}
