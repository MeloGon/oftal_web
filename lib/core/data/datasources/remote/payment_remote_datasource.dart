import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:oftal_web/shared/models/payment_model.dart';

abstract class PaymentRemoteDataSource {
  Future<void> insertPayment(PaymentModel payment);
  Future<List<PaymentModel>> getPaymentsByRemision(String idRemision);
  Future<void> deletePaymentsByRemision(String idRemision);
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
}
