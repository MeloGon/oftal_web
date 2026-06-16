import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:oftal_web/shared/models/payment_model.dart';
import 'package:oftal_web/shared/models/daily_payment_model.dart';

abstract class PaymentRemoteDataSource {
  Future<void> insertPayment(PaymentModel payment);
  Future<List<PaymentModel>> getPaymentsByRemision(String idRemision);
  Future<void> deletePaymentsByRemision(String idRemision);
  Future<List<DailyPaymentModel>> getPaymentsByDateRange(String from, String to);
}

class PaymentRemoteDataSourceImpl implements PaymentRemoteDataSource {
  final SupabaseClient client;
  PaymentRemoteDataSourceImpl(this.client);

  @override
  Future<void> insertPayment(PaymentModel payment) async {
    await client.from('pagos').insert(payment.toInsertJson());
  }

  @override
  Future<List<PaymentModel>> getPaymentsByRemision(String idRemision) async {
    final response = await client
        .from('pagos')
        .select()
        .eq('id_remision', idRemision)
        .order('fecha_pago', ascending: true);
    return response.map((json) => PaymentModel.fromJson(json)).toList();
  }

  @override
  Future<void> deletePaymentsByRemision(String idRemision) async {
    await client.from('pagos').delete().eq('id_remision', idRemision);
  }

  @override
  Future<List<DailyPaymentModel>> getPaymentsByDateRange(
    String from,
    String to,
  ) async {
    final paymentsResponse = await client
        .from('pagos')
        .select()
        .gte('fecha_pago', from)
        .lte('fecha_pago', to)
        .order('fecha_pago', ascending: true)
        .order('id', ascending: true);

    if (paymentsResponse.isEmpty) return [];

    final remisionIds = paymentsResponse
        .map((p) => p['id_remision'] as String)
        .toSet()
        .toList();

    final salesResponse = await client
        .from('ventas cortas')
        .select('"ID REMISION", "PACIENTE", "FOLIO REMISION", "SUCURSAL", "TOTAL CON DESCUENTO", "TOTAL", "RESTA"')
        .inFilter('ID REMISION', remisionIds);

    final salesMap = <String, Map<String, dynamic>>{};
    for (final sale in salesResponse) {
      salesMap[sale['ID REMISION'] as String] = sale;
    }

    return paymentsResponse.map((json) {
      final idRemision = json['id_remision'] as String;
      return DailyPaymentModel.fromJson(json, salesMap[idRemision]);
    }).toList();
  }
}
