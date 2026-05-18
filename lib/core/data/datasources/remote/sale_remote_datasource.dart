import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:oftal_web/shared/models/shared_models.dart';

abstract class SaleRemoteDataSource {
  Future<List<SalesModel>> getSalesByFilter(
    String filter,
    String query, {
    bool isDate = false,
    bool onlyPending = false,
  });
  Future<List<SalesModel>> getRecentSales({
    int limit = 20,
    bool onlyPending = false,
  });
  Future<int> countSalesToday({required String authorName});
  Future<int> countPatientsByBranch({required String branch});
  Future<List<String>> getSalesDatesInRange({
    required String branch,
    required String from,
    required String to,
  });
  Future<List<SalesDetailsModel>> getSaleDetails(String folioSale);
  Future<void> insertSalesDetails(List<SalesDetailsModel> items);
  Future<void> insertShortSale(SalesModel sale);
  Future<void> deleteShortSale(String folioSale);
  Future<void> deleteSaleDetails(String idRemision);
  Future<void> updateShortSale(SalesModel sale);
  Future<void> updateAccountPayment(
    String idRemision,
    double newAccount,
    double newRest,
    String fechaPago,
  );
  Future<void> updateSaleDate(
    String folioSale,
    String fecha,
    String fechaActualizada,
  );
}

class SaleRemoteDataSourceImpl implements SaleRemoteDataSource {
  final SupabaseClient client;
  SaleRemoteDataSourceImpl(this.client);

  @override
  Future<List<SalesModel>> getSalesByFilter(
    String filter,
    String query, {
    bool isDate = false,
    bool onlyPending = false,
  }) async {
    var q = client.from('ventas cortas').select();
    if (isDate) {
      q = q.eq(filter, query);
    } else {
      q = q.textSearch(filter, '%$query%', type: TextSearchType.plain);
    }
    if (onlyPending) q = q.gt('RESTA', 0);
    final response = isDate
        ? await q.order('fecha_actualizada', ascending: false)
        : await q;
    return response.map((json) => SalesModel.fromJson(json)).toList();
  }

  @override
  Future<List<SalesModel>> getRecentSales({
    int limit = 20,
    bool onlyPending = false,
  }) async {
    var q = client.from('ventas cortas').select();
    if (onlyPending) q = q.gt('RESTA', 0);
    final response = await q
        .limit(limit)
        .order('fecha_actualizada', ascending: false);
    return response.map((json) => SalesModel.fromJson(json)).toList();
  }

  @override
  Future<int> countSalesToday({required String authorName}) async {
    final response = await client
        .from('ventas cortas')
        .select('*')
        .eq('"AUTOR NOMBRE"', authorName)
        .eq(
          '"fecha_actualizada"',
          DateFormat('yyyy-MM-dd').format(DateTime.now()),
        )
        .count();
    return response.count;
  }

  @override
  Future<int> countPatientsByBranch({required String branch}) async {
    final response = await client
        .from('pacientes')
        .select('*')
        .eq('"SUCURSAL"', branch)
        .count();
    return response.count;
  }

  @override
  Future<List<SalesDetailsModel>> getSaleDetails(String folioSale) async {
    final response = await client
        .from('ventas')
        .select()
        .eq('FOLIO DE VENTA', folioSale);
    return response.map((json) => SalesDetailsModel.fromJson(json)).toList();
  }

  @override
  Future<void> insertSalesDetails(List<SalesDetailsModel> items) async {
    await client.from('ventas').insert(items.map((e) => e.toJson()).toList());
  }

  @override
  Future<void> insertShortSale(SalesModel sale) async {
    await client.from('ventas cortas').insert(sale.toJson());
  }

  @override
  Future<void> deleteShortSale(String folioSale) async {
    await client.from('ventas cortas').delete().eq('FOLIO REMISION', folioSale);
  }

  @override
  Future<void> deleteSaleDetails(String idRemision) async {
    await client.from('ventas').delete().eq('ID REMISION', idRemision);
  }

  @override
  Future<void> updateShortSale(SalesModel sale) async {
    await client.from('ventas cortas').update({
      'TOTAL': sale.total,
      'DESCUENTO': sale.discount,
      'TOTAL CON DESCUENTO': sale.totalWithDiscount,
      'A CUENTA': sale.account,
      'RESTA': sale.rest,
    }).eq('FOLIO REMISION', sale.folioSale!);
  }

  @override
  Future<List<String>> getSalesDatesInRange({
    required String branch,
    required String from,
    required String to,
  }) async {
    final response = await client
        .from('ventas cortas')
        .select('"fecha_actualizada"')
        .eq('"SUCURSAL"', branch)
        .gte('"fecha_actualizada"', from)
        .lte('"fecha_actualizada"', to);
    return response
        .map((r) => r['fecha_actualizada']?.toString() ?? '')
        .where((d) => d.isNotEmpty)
        .toList();
  }

  @override
  Future<void> updateSaleDate(
    String folioSale,
    String fecha,
    String fechaActualizada,
  ) async {
    await client.from('ventas cortas').update({
      'FECHA': fecha,
      'fecha_actualizada': fechaActualizada,
    }).eq('FOLIO REMISION', folioSale);
  }

  @override
  Future<void> updateAccountPayment(
    String idRemision,
    double newAccount,
    double newRest,
    String fechaPago,
  ) async {
    await client.from('ventas cortas').update({
      'A CUENTA': newAccount,
      'RESTA': newRest,
      'fecha_actualizada': fechaPago,
    }).eq('ID REMISION', idRemision);
  }
}
