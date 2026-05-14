import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:oftal_web/shared/models/shared_models.dart';

abstract class MountRemoteDataSource {
  Future<List<MountModel>> searchMounts(String query);
  Future<({List<MountModel> items, bool hasMore})> fetchPage({
    required int offset,
    required int limit,
  });
  Future<MountModel> getMountById(int id);
  Future<void> insertMount(MountModel mount);
  Future<void> updateMount(MountModel mount);
  Future<void> deleteMount(int id);
  Future<void> decrementStock(int id, int currentStock);
  Future<void> incrementStock(int id);
}

class MountRemoteDataSourceImpl implements MountRemoteDataSource {
  final SupabaseClient client;
  MountRemoteDataSourceImpl(this.client);

  @override
  Future<List<MountModel>> searchMounts(String query) async {
    final response = await client
        .from('armazones')
        .select()
        .or('MARCA.ilike.%$query%,MODELO.ilike.%$query%');
    return response.map((json) => MountModel.fromJson(json)).toList();
  }

  @override
  Future<({List<MountModel> items, bool hasMore})> fetchPage({
    required int offset,
    required int limit,
  }) async {
    final end = offset + limit - 1;
    final response = await client
        .from('armazones')
        .select()
        .order('CREADO EL', ascending: false)
        .range(offset, end);
    final items = response.map((json) => MountModel.fromJson(json)).toList();
    return (items: items, hasMore: items.length == limit);
  }

  @override
  Future<MountModel> getMountById(int id) async {
    final response = await client
        .from('armazones')
        .select('*')
        .eq('ID ARMAZON', id);
    return MountModel.fromJson(response.first);
  }

  @override
  Future<void> insertMount(MountModel mount) async {
    await client.from('armazones').insert(mount.toJson());
  }

  @override
  Future<void> updateMount(MountModel mount) async {
    await client
        .from('armazones')
        .update(mount.toJson())
        .eq('ID ARMAZON', mount.id);
  }

  @override
  Future<void> deleteMount(int id) async {
    await client.from('armazones').delete().eq('ID ARMAZON', id);
  }

  @override
  Future<void> decrementStock(int id, int currentStock) async {
    await client
        .from('armazones')
        .update({'EXISTENCIAS': currentStock > 1 ? currentStock - 1 : 0})
        .eq('ID ARMAZON', id);
  }

  @override
  Future<void> incrementStock(int id) async {
    final response = await client
        .from('armazones')
        .select('EXISTENCIAS')
        .eq('ID ARMAZON', id)
        .maybeSingle();
    if (response == null) return;
    final current = (response['EXISTENCIAS'] as int?) ?? 0;
    await client
        .from('armazones')
        .update({'EXISTENCIAS': current + 1})
        .eq('ID ARMAZON', id);
  }
}
