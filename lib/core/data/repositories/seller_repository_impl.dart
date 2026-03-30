import 'package:fpdart/fpdart.dart';
import 'package:oftal_web/core/data/datasources/remote/seller_remote_datasource.dart';
import 'package:oftal_web/core/domain/repositories/seller_repository.dart';
import 'package:oftal_web/core/errors/failures.dart';
import 'package:oftal_web/shared/models/shared_models.dart';

class SellerRepositoryImpl implements SellerRepository {
  final SellerRemoteDataSource _dataSource;
  SellerRepositoryImpl(this._dataSource);

  @override
  Future<Either<Failure, List<SellerModel>>> getSellers() async {
    try {
      return Right(await _dataSource.getSellers());
    } catch (e) {
      return Left(Failure.server(e.toString()));
    }
  }
}
