import 'package:fpdart/fpdart.dart';
import 'package:oftal_web/core/data/datasources/remote/payment_remote_datasource.dart';
import 'package:oftal_web/core/domain/repositories/payment_repository.dart';
import 'package:oftal_web/core/errors/failures.dart';
import 'package:oftal_web/shared/models/payment_model.dart';
import 'package:oftal_web/shared/models/daily_payment_model.dart';

class PaymentRepositoryImpl implements PaymentRepository {
  final PaymentRemoteDataSource _dataSource;
  PaymentRepositoryImpl(this._dataSource);

  @override
  Future<Either<Failure, Unit>> insertPayment(PaymentModel payment) async {
    try {
      await _dataSource.insertPayment(payment);
      return const Right(unit);
    } catch (e) {
      return Left(Failure.server(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<PaymentModel>>> getPaymentsByRemision(
    String idRemision,
  ) async {
    try {
      return Right(await _dataSource.getPaymentsByRemision(idRemision));
    } catch (e) {
      return Left(Failure.server(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> deletePaymentsByRemision(
    String idRemision,
  ) async {
    try {
      await _dataSource.deletePaymentsByRemision(idRemision);
      return const Right(unit);
    } catch (e) {
      return Left(Failure.server(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<DailyPaymentModel>>> getPaymentsByDateRange(
    String from,
    String to,
  ) async {
    try {
      return Right(await _dataSource.getPaymentsByDateRange(from, to));
    } catch (e) {
      return Left(Failure.server(e.toString()));
    }
  }
}
