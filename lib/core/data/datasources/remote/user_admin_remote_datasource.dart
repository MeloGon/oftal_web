import 'package:oftal_web/shared/models/profile_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Edge Function `megadmin-users`: corre con `service_role` en Supabase y
/// exige que quien llama tenga `perfiles.rol == 'megadmin'`.
const String _kMegadminUsersFunction = 'megadmin-users';

abstract class UserAdminRemoteDataSource {
  Future<List<ProfileModel>> listUsers();
  Future<void> resetPassword({
    required String userId,
    required String newPassword,
  });
}

class UserAdminRemoteDataSourceImpl implements UserAdminRemoteDataSource {
  final SupabaseClient client;
  UserAdminRemoteDataSourceImpl(this.client);

  @override
  Future<List<ProfileModel>> listUsers() async {
    final response = await client.functions.invoke(
      _kMegadminUsersFunction,
      body: {'action': 'list'},
    );
    final data = response.data;
    final rawUsers = data is Map ? data['users'] : null;
    if (rawUsers is! List) {
      throw Exception('Respuesta inesperada del servidor.');
    }
    return rawUsers
        .map((json) => ProfileModel.fromJson(Map<String, Object?>.from(json)))
        .toList();
  }

  @override
  Future<void> resetPassword({
    required String userId,
    required String newPassword,
  }) async {
    await client.functions.invoke(
      _kMegadminUsersFunction,
      body: {
        'action': 'reset_password',
        'userId': userId,
        'newPassword': newPassword,
      },
    );
  }
}

/// Extrae un mensaje legible de un `FunctionException` lanzado por
/// `client.functions.invoke` (ver `functions_client` package).
String functionErrorMessage(Object error) {
  if (error is FunctionException) {
    final details = error.details;
    if (details is Map && details['error'] is String) {
      return details['error'] as String;
    }
    if (details is String && details.isNotEmpty) return details;
    return 'Error del servidor (${error.status}).';
  }
  return error.toString();
}
