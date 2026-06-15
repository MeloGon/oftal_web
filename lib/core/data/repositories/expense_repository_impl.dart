import 'package:fpdart/fpdart.dart';
import 'package:oftal_web/core/data/datasources/remote/expense_remote_datasource.dart';
import 'package:oftal_web/core/domain/repositories/expense_repository.dart';
import 'package:oftal_web/core/errors/failures.dart';
import 'package:oftal_web/shared/models/shared_models.dart';

class ExpenseRepositoryImpl implements ExpenseRepository {
  final ExpenseRemoteDataSource _dataSource;
  ExpenseRepositoryImpl(this._dataSource);

  @override
  Future<Either<Failure, ({List<ExpenseModel> items, bool hasMore})>>
      getExpenses({
    String? search,
    String? branch,
    String? registeredBy,
    int offset = 0,
    int limit = 20,
  }) async {
    try {
      return Right(await _dataSource.getExpenses(
        search: search,
        branch: branch,
        registeredBy: registeredBy,
        offset: offset,
        limit: limit,
      ));
    } catch (e) {
      return Left(Failure.server(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<ExpenseModel>>> getExpensesByDateRange(
    String from,
    String to,
  ) async {
    try {
      return Right(await _dataSource.getExpensesByDateRange(from, to));
    } catch (e) {
      return Left(Failure.server(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> insertExpense(ExpenseModel expense) async {
    try {
      await _dataSource.insertExpense(expense);
      return const Right(unit);
    } catch (e) {
      return Left(Failure.server(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> updateExpense(ExpenseModel expense) async {
    try {
      await _dataSource.updateExpense(expense);
      return const Right(unit);
    } catch (e) {
      return Left(Failure.server(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteExpense(String id) async {
    try {
      await _dataSource.deleteExpense(id);
      return const Right(unit);
    } catch (e) {
      return Left(Failure.server(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<ExpenseCategoryModel>>> getCategories() async {
    try {
      return Right(await _dataSource.getCategories());
    } catch (e) {
      return Left(Failure.server(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> insertCategory(
    ExpenseCategoryModel category,
  ) async {
    try {
      await _dataSource.insertCategory(category);
      return const Right(unit);
    } catch (e) {
      return Left(Failure.server(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteCategory(int id) async {
    try {
      await _dataSource.deleteCategory(id);
      return const Right(unit);
    } catch (e) {
      return Left(Failure.server(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Map<String, double>>> getExpensesByCategory(
    String from,
    String to,
  ) async {
    try {
      return Right(await _dataSource.getExpensesByCategory(from, to));
    } catch (e) {
      return Left(Failure.server(e.toString()));
    }
  }
}
