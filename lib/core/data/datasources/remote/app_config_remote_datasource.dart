import 'package:supabase_flutter/supabase_flutter.dart';

abstract class AppConfigRemoteDataSource {
  Future<Map<String, String>> getAll();
  Future<void> setValue(String key, String value);
}

class AppConfigRemoteDataSourceImpl implements AppConfigRemoteDataSource {
  AppConfigRemoteDataSourceImpl(this.client);
  final SupabaseClient client;

  @override
  Future<Map<String, String>> getAll() async {
    final response = await client
        .from('app_config')
        .select('key, value');
    return {for (final row in response) row['key'] as String: row['value'] as String};
  }

  @override
  Future<void> setValue(String key, String value) async {
    await client.from('app_config').update({
      'value': value,
      'updated_at': DateTime.now().toIso8601String(),
    }).eq('key', key);
  }
}
