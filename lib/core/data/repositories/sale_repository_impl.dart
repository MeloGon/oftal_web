import 'package:fpdart/fpdart.dart';
import 'package:oftal_web/core/data/datasources/remote/sale_remote_datasource.dart';
import 'package:oftal_web/core/domain/repositories/sale_repository.dart';
import 'package:oftal_web/core/errors/failures.dart';
import 'package:oftal_web/shared/models/shared_models.dart';

class SaleRepositoryImpl implements SaleRepository {
  final SaleRemoteDataSource _dataSource;
  SaleRepositoryImpl(this._dataSource);

  @override
  Future<Either<Failure, List<SalesModel>>> getSalesByFilter(
    String filter,
    String query, {
    bool isDate = false,
  }) async {
    try {
      return Right(
        await _dataSource.getSalesByFilter(filter, query, isDate: isDate),
      );
    } catch (e) {
      return Left(Failure.server(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<SalesModel>>> getRecentSales({
    int limit = 20,
  }) async {
    try {
      return Right(await _dataSource.getRecentSales(limit: limit));
    } catch (e) {
      return Left(Failure.server(e.toString()));
    }
  }

  @override
  Future<Either<Failure, int>> countSalesToday({
    required String authorName,
  }) async {
    try {
      return Right(
        await _dataSource.countSalesToday(authorName: authorName),
      );
    } catch (e) {
      return Left(Failure.server(e.toString()));
    }
  }

  @override
  Future<Either<Failure, int>> countPatientsByBranch({
    required String branch,
  }) async {
    try {
      return Right(
        await _dataSource.countPatientsByBranch(branch: branch),
      );
    } catch (e) {
      return Left(Failure.server(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<SalesDetailsModel>>> getSaleDetails(
    String folioSale,
  ) async {
    try {
      return Right(await _dataSource.getSaleDetails(folioSale));
    } catch (e) {
      return Left(Failure.server(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> insertSalesDetails(
    List<SalesDetailsModel> items,
  ) async {
    try {
      await _dataSource.insertSalesDetails(items);
      return const Right(unit);
    } catch (e) {
      return Left(Failure.server(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> insertShortSale(SalesModel sale) async {
    try {
      await _dataSource.insertShortSale(sale);
      return const Right(unit);
    } catch (e) {
      return Left(Failure.server(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteSale(String folioSale) async {
    try {
      await _dataSource.deleteShortSale(folioSale);
      await _dataSource.deleteSaleDetails(folioSale);
      return const Right(unit);
    } catch (e) {
      return Left(Failure.server(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> updateShortSale(SalesModel sale) async {
    try {
      await _dataSource.updateShortSale(sale);
      return const Right(unit);
    } catch (e) {
      return Left(Failure.server(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> updateAccountPayment(
    String idRemision,
    double newAccount,
    double newRest,
    String fechaPago,
  ) async {
    try {
      await _dataSource.updateAccountPayment(
        idRemision,
        newAccount,
        newRest,
        fechaPago,
      );
      return const Right(unit);
    } catch (e) {
      return Left(Failure.server(e.toString()));
    }
  }
}
