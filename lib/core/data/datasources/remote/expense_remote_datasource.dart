import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:oftal_web/shared/models/shared_models.dart';

abstract class ExpenseRemoteDataSource {
  Future<({List<ExpenseModel> items, bool hasMore})> getExpenses({
    String? search,
    String? branch,
    String? registeredBy,
    int offset = 0,
    int limit = 20,
  });
  Future<List<ExpenseModel>> getExpensesByDateRange(String from, String to);
  Future<void> insertExpense(ExpenseModel expense);
  Future<void> updateExpense(ExpenseModel expense);
  Future<void> deleteExpense(String id);
  Future<List<ExpenseCategoryModel>> getCategories();
  Future<void> insertCategory(ExpenseCategoryModel category);
  Future<void> deleteCategory(int id);
  Future<Map<String, double>> getExpensesByCategory(String from, String to);
}

class ExpenseRemoteDataSourceImpl implements ExpenseRemoteDataSource {
  final SupabaseClient client;
  ExpenseRemoteDataSourceImpl(this.client);

  @override
  Future<({List<ExpenseModel> items, bool hasMore})> getExpenses({
    String? search,
    String? branch,
    String? registeredBy,
    int offset = 0,
    int limit = 20,
  }) async {
    var query = client
        .from('egresos')
        .select('*, categorias_egresos(nombre, color)');

    if (search != null && search.isNotEmpty) {
      query = query.or('descripcion.ilike.%$search%,comprobante.ilike.%$search%');
    }
    if (branch != null) {
      query = query.eq('sucursal', branch);
    }
    if (registeredBy != null) {
      query = query.eq('registrado_por', registeredBy);
    }

    final response = await query
        .order('fecha', ascending: false)
        .range(offset, offset + limit);
    final rows =
        response.map((json) => ExpenseModel.fromJson(json)).toList();
    final hasMore = rows.length > limit;
    return (
      items: hasMore ? rows.sublist(0, limit) : rows,
      hasMore: hasMore,
    );
  }

  @override
  Future<List<ExpenseModel>> getExpensesByDateRange(
    String from,
    String to,
  ) async {
    final response = await client
        .from('egresos')
        .select('*, categorias_egresos(nombre, color)')
        .gte('fecha', from)
        .lte('fecha', to)
        .order('fecha', ascending: false);
    return response.map((json) => ExpenseModel.fromJson(json)).toList();
  }

  @override
  Future<void> insertExpense(ExpenseModel expense) async {
    await client.from('egresos').insert(expense.toInsertJson());
  }

  @override
  Future<void> updateExpense(ExpenseModel expense) async {
    await client
        .from('egresos')
        .update(expense.toInsertJson())
        .eq('id', expense.id!);
  }

  @override
  Future<void> deleteExpense(String id) async {
    await client.from('egresos').delete().eq('id', id);
  }

  @override
  Future<List<ExpenseCategoryModel>> getCategories() async {
    final response = await client
        .from('categorias_egresos')
        .select()
        .order('nombre');
    return response
        .map((json) => ExpenseCategoryModel.fromJson(json))
        .toList();
  }

  @override
  Future<void> insertCategory(ExpenseCategoryModel category) async {
    await client.from('categorias_egresos').insert(category.toJson());
  }

  @override
  Future<void> deleteCategory(int id) async {
    await client.from('categorias_egresos').delete().eq('id', id);
  }

  @override
  Future<Map<String, double>> getExpensesByCategory(
    String from,
    String to,
  ) async {
    final response = await client
        .from('egresos')
        .select('monto, categorias_egresos(nombre)')
        .gte('fecha', from)
        .lte('fecha', to);

    final result = <String, double>{};
    for (final row in response) {
      final cat =
          (row['categorias_egresos'] as Map<String, dynamic>?)?['nombre']
              as String? ??
          'Sin categoría';
      final amount = _toDouble(row['monto']);
      result[cat] = (result[cat] ?? 0) + amount;
    }
    return result;
  }
}

double _toDouble(dynamic value) {
  if (value == null) return 0.0;
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value) ?? 0.0;
  return 0.0;
}
