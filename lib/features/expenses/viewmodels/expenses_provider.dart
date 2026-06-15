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
    final result = await ref.read(expenseRepositoryProvider).getExpenses(
          search: state.searchQuery.isEmpty ? null : state.searchQuery,
          branch: state.filterBranch,
          registeredBy: state.filterRegisteredBy,
          offset: state.offset,
          limit: state.rowsPerPage,
        );
    result.fold(
      (f) => state = state.copyWith(
        isLoading: false,
        errorMessage: f.message,
        snackbarConfig: SnackbarConfigModel(
          title: 'Error',
          type: SnackbarEnum.error,
        ),
      ),
      (data) => state = state.copyWith(
        expenses: data.items,
        hasMore: data.hasMore,
        isLoading: false,
      ),
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
          offset: 0,
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

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query, offset: 0);
    getExpenses();
  }

  void setBranchFilter(String? branch) {
    state = state.copyWith(filterBranch: branch, offset: 0);
    getExpenses();
  }

  void setRegisteredByFilter(String? registeredBy) {
    state = state.copyWith(filterRegisteredBy: registeredBy, offset: 0);
    getExpenses();
  }

  void clearFilters() {
    state = state.copyWith(
      searchQuery: '',
      filterBranch: null,
      filterRegisteredBy: null,
      offset: 0,
    );
    getExpenses();
  }

  void nextPage() {
    if (!state.hasMore) return;
    state = state.copyWith(offset: state.offset + state.rowsPerPage);
    getExpenses();
  }

  void prevPage() {
    if (state.offset == 0) return;
    final newOffset = (state.offset - state.rowsPerPage).clamp(0, 1 << 31);
    state = state.copyWith(offset: newOffset);
    getExpenses();
  }

  void clearErrorMessage() =>
      state = state.copyWith(errorMessage: '', snackbarConfig: null);
}
