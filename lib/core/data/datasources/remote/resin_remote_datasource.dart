import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:oftal_web/shared/models/shared_models.dart';

abstract class ResinRemoteDataSource {
  Future<List<ResinModel>> searchResins(String query);
  Future<({List<ResinModel> items, bool hasMore})> fetchPage({
    required int offset,
    required int limit,
  });
  Future<void> insertResin(ResinModel resin);
  Future<void> updateResin(ResinModel resin);
  Future<void> deleteResin(int id);
}

class ResinRemoteDataSourceImpl implements ResinRemoteDataSource {
  final SupabaseClient client;
  ResinRemoteDataSourceImpl(this.client);

  @override
  Future<List<ResinModel>> searchResins(String query) async {
    final response = await client
        .from('resinas')
        .select()
        .ilike('texto', '%$query%');
    return response.map((json) => ResinModel.fromJson(json)).toList();
  }

  @override
  Future<({List<ResinModel> items, bool hasMore})> fetchPage({
    required int offset,
    required int limit,
  }) async {
    final end = offset + limit - 1;
    final response = await client
        .from('resinas')
        .select()
        .order('CREADO EL', ascending: false)
        .range(offset, end);
    final items = response.map((json) => ResinModel.fromJson(json)).toList();
    return (items: items, hasMore: items.length == limit);
  }

  @override
  Future<void> insertResin(ResinModel resin) async {
    await client.from('resinas').insert(resin.toJson());
  }

  @override
  Future<void> updateResin(ResinModel resin) async {
    await client
        .from('resinas')
        .update(resin.toJson())
        .eq('id_oftalmico', resin.id);
  }

  @override
  Future<void> deleteResin(int id) async {
    await client.from('resinas').delete().eq('id_oftalmico', id);
  }
}
