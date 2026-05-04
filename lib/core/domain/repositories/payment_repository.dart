import 'package:fpdart/fpdart.dart';
import 'package:oftal_web/core/errors/failures.dart';
import 'package:oftal_web/shared/models/payment_model.dart';

abstract class PaymentRepository {
  Future<Either<Failure, Unit>> insertPayment(PaymentModel payment);
  Future<Either<Failure, List<PaymentModel>>> getPaymentsByRemision(String idRemision);
  Future<Either<Failure, Unit>> deletePaymentsByRemision(String idRemision);
}
