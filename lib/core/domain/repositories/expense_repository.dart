import 'package:fpdart/fpdart.dart';
import 'package:oftal_web/core/errors/failures.dart';
import 'package:oftal_web/shared/models/shared_models.dart';

abstract class ExpenseRepository {
  Future<Either<Failure, List<ExpenseModel>>> getExpenses({int limit = 50});
  Future<Either<Failure, List<ExpenseModel>>> getExpensesByDateRange(
    String from,
    String to,
  );
  Future<Either<Failure, Unit>> insertExpense(ExpenseModel expense);
  Future<Either<Failure, Unit>> updateExpense(ExpenseModel expense);
  Future<Either<Failure, Unit>> deleteExpense(String id);
  Future<Either<Failure, List<ExpenseCategoryModel>>> getCategories();
  Future<Either<Failure, Unit>> insertCategory(ExpenseCategoryModel category);
  Future<Either<Failure, Unit>> deleteCategory(int id);
  Future<Either<Failure, Map<String, double>>> getExpensesByCategory(
    String from,
    String to,
  );
}
