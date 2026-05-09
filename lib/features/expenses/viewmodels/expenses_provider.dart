import 'package:oftal_web/core/data/providers/infrastructure_providers.dart';
import 'package:oftal_web/core/enums/enums.dart';
import 'package:oftal_web/features/expenses/viewmodels/expenses_state.dart';
import 'package:oftal_web/shared/models/shared_models.dart';
import 'package:oftal_web/shared/services/local_storage.dart' as local_storage;
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'expenses_provider.g.dart';

// FutureProvider (no build_runner) para el donut del dashboard
final expensesSummaryProvider = FutureProvider<Map<String, double>>((ref) async {
  final now = DateTime.now();
  final from =
      '${now.year}-${now.month.toString().padLeft(2, '0')}-01';
  final to = now.toIso8601String().substring(0, 10);
  final result = await ref
      .read(expenseRepositoryProvider)
      .getExpensesByCategory(from, to);
  return result.fold((_) => <String, double>{}, (data) => data);
});

@Riverpod(keepAlive: true)
class Expenses extends _$Expenses {
  @override
  ExpensesState build() {
    Future.microtask(_init);
    return const ExpensesState();
  }

  Future<void> _init() async {
    await Future.wait([getExpenses(), getCategories()]);
  }

  Future<void> getExpenses() async {
    state = state.copyWith(isLoading: true);
    final result =
        await ref.read(expenseRepositoryProvider).getExpenses();
    result.fold(
      (f) => state = state.copyWith(
        isLoading: false,
        errorMessage: f.message,
        snackbarConfig: SnackbarConfigModel(
          title: 'Error',
          type: SnackbarEnum.error,
        ),
      ),
      (list) => state = state.copyWith(expenses: list, isLoading: false),
    );
  }

  Future<void> getCategories() async {
    final result =
        await ref.read(expenseRepositoryProvider).getCategories();
    result.fold(
      (_) => null,
      (list) => state = state.copyWith(categories: list),
    );
  }

  Future<void> insertExpense(ExpenseModel expense) async {
    state = state.copyWith(isLoading: true);
    final profile = await local_storage.LocalStorage.getProfile();
    final withUser = ExpenseModel(
      fecha: expense.fecha,
      categoriaId: expense.categoriaId,
      descripcion: expense.descripcion,
      monto: expense.monto,
      metodoPago: expense.metodoPago,
      comprobante: expense.comprobante,
      sucursal: expense.sucursal,
      registradoPor: profile.name,
      notas: expense.notas,
    );
    final result =
        await ref.read(expenseRepositoryProvider).insertExpense(withUser);
    result.fold(
      (f) => state = state.copyWith(
        isLoading: false,
        errorMessage: f.message,
        snackbarConfig: SnackbarConfigModel(
          title: 'Error',
          type: SnackbarEnum.error,
        ),
      ),
      (_) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'Egreso registrado correctamente',
          snackbarConfig: SnackbarConfigModel(
            title: 'Aviso',
            type: SnackbarEnum.success,
          ),
        );
        getExpenses();
      },
    );
  }

  Future<void> updateExpense(ExpenseModel expense) async {
    state = state.copyWith(isLoading: true);
    final result =
        await ref.read(expenseRepositoryProvider).updateExpense(expense);
    result.fold(
      (f) => state = state.copyWith(
        isLoading: false,
        errorMessage: f.message,
        snackbarConfig: SnackbarConfigModel(
          title: 'Error',
          type: SnackbarEnum.error,
        ),
      ),
      (_) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'Egreso actualizado correctamente',
          snackbarConfig: SnackbarConfigModel(
            title: 'Aviso',
            type: SnackbarEnum.success,
          ),
        );
        getExpenses();
      },
    );
  }

  Future<void> deleteExpense(String id) async {
    state = state.copyWith(isLoading: true);
    final result =
        await ref.read(expenseRepositoryProvider).deleteExpense(id);
    result.fold(
      (f) => state = state.copyWith(
        isLoading: false,
        errorMessage: f.message,
        snackbarConfig: SnackbarConfigModel(
          title: 'Error',
          type: SnackbarEnum.error,
        ),
      ),
      (_) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'Egreso eliminado correctamente',
          snackbarConfig: SnackbarConfigModel(
            title: 'Aviso',
            type: SnackbarEnum.success,
          ),
        );
        getExpenses();
      },
    );
  }

  Future<void> insertCategory(ExpenseCategoryModel category) async {
    final result =
        await ref.read(expenseRepositoryProvider).insertCategory(category);
    result.fold(
      (f) => state = state.copyWith(
        errorMessage: f.message,
        snackbarConfig: SnackbarConfigModel(
          title: 'Error',
          type: SnackbarEnum.error,
        ),
      ),
      (_) => getCategories(),
    );
  }

  Future<void> deleteCategory(int id) async {
    final result =
        await ref.read(expenseRepositoryProvider).deleteCategory(id);
    result.fold(
      (f) => state = state.copyWith(
        errorMessage: f.message,
        snackbarConfig: SnackbarConfigModel(
          title: 'Error',
          type: SnackbarEnum.error,
        ),
      ),
      (_) => getCategories(),
    );
  }

  void changeRowsPerPage(int value) =>
      state = state.copyWith(rowsPerPage: value);

  void clearErrorMessage() =>
      state = state.copyWith(errorMessage: '', snackbarConfig: null);
}
