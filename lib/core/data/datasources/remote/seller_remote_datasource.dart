import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:oftal_web/shared/models/shared_models.dart';

abstract class SellerRemoteDataSource {
  Future<List<SellerModel>> getSellers();
}

class SellerRemoteDataSourceImpl implements SellerRemoteDataSource {
  final SupabaseClient client;
  SellerRemoteDataSourceImpl(this.client);

  @override
  Future<List<SellerModel>> getSellers() async {
    final response = await client.from('vendedores').select();
    return response.map((json) => SellerModel.fromJson(json)).toList();
  }
}
