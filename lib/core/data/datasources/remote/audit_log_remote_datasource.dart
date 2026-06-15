import 'package:oftal_web/shared/models/audit_log_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract class AuditLogRemoteDataSource {
  Future<void> insert({
    required String action,
    required String entity,
    required String entityId,
    required String userEmail,
    required Map<String, dynamic> detail,
  });

  Future<List<AuditLogModel>> getRecent({int limit = 5});

  Future<({List<AuditLogModel> items, bool hasMore})> getAll({
    String? action,
    String? userEmail,
    DateTime? from,
    DateTime? to,
    int offset = 0,
    int limit = 20,
  });
}

class AuditLogRemoteDataSourceImpl implements AuditLogRemoteDataSource {
  AuditLogRemoteDataSourceImpl(this._client);
  final SupabaseClient _client;

  @override
  Future<void> insert({
    required String action,
    required String entity,
    required String entityId,
    required String userEmail,
    required Map<String, dynamic> detail,
  }) async {
    await _client.from('audit_logs').insert({
      'action': action,
      'entity': entity,
      'entity_id': entityId,
      'user_email': userEmail,
      'detail': detail,
    });
  }

  @override
  Future<List<AuditLogModel>> getRecent({int limit = 5}) async {
    final response = await _client
        .from('audit_logs')
        .select()
        .order('created_at', ascending: false)
        .limit(limit);
    return response.map((r) => AuditLogModel.fromJson(r)).toList();
  }

  @override
  Future<({List<AuditLogModel> items, bool hasMore})> getAll({
    String? action,
    String? userEmail,
    DateTime? from,
    DateTime? to,
    int offset = 0,
    int limit = 20,
  }) async {
    var query = _client.from('audit_logs').select();

    if (action != null) query = query.eq('action', action);
    if (userEmail != null) query = query.eq('user_email', userEmail);
    if (from != null) {
      query = query.gte('created_at', from.toIso8601String());
    }
    if (to != null) {
      query = query.lte('created_at', to.toIso8601String());
    }

    // Fetch limit+1 to detect if more pages exist without a count query.
    final response = await query
        .order('created_at', ascending: false)
        .range(offset, offset + limit);
    final rows = response.map((r) => AuditLogModel.fromJson(r)).toList();
    final hasMore = rows.length > limit;
    return (
      items: hasMore ? rows.sublist(0, limit) : rows,
      hasMore: hasMore,
    );
  }
}
