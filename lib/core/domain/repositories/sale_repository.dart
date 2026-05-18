import 'package:fpdart/fpdart.dart';
import 'package:oftal_web/core/errors/failures.dart';
import 'package:oftal_web/shared/models/shared_models.dart';

abstract class SaleRepository {
  Future<Either<Failure, List<SalesModel>>> getSalesByFilter(
    String filter,
    String query, {
    bool isDate = false,
    bool onlyPending = false,
  });
  Future<Either<Failure, List<SalesModel>>> getRecentSales({
    int limit = 20,
    bool onlyPending = false,
  });
  Future<Either<Failure, int>> countSalesToday({required String authorName});
  Future<Either<Failure, int>> countPatientsByBranch({required String branch});
  Future<Either<Failure, List<SalesDetailsModel>>> getSaleDetails(
    String folioSale,
  );
  Future<Either<Failure, Unit>> insertSalesDetails(
    List<SalesDetailsModel> items,
  );
  Future<Either<Failure, Unit>> insertShortSale(SalesModel sale);
  Future<Either<Failure, Unit>> deleteSale(String folioSale);
  Future<Either<Failure, Unit>> updateShortSale(SalesModel sale);
  Future<Either<Failure, List<String>>> getSalesDatesInRange({
    required String branch,
    required String from,
    required String to,
  });
  Future<Either<Failure, Unit>> updateAccountPayment(
    String idRemision,
    double newAccount,
    double newRest,
    String fechaPago,
  );
  Future<Either<Failure, Unit>> updateSaleDate(
    String folioSale,
    String fecha,
    String fechaActualizada,
  );
}
