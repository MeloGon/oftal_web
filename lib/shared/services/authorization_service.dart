import 'package:oftal_web/core/constants/app_enviroment.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

enum AuthorizationRole { supervisor, admin }

class AuthorizationService {
  /// Verifica credenciales de un supervisor/admin sin afectar la sesión activa.
  /// Crea un cliente Supabase temporal independiente para autenticar.
  static Future<bool> authorize({
    required String email,
    required String password,
    required AuthorizationRole requiredRole,
  }) async {
    final tempClient = SupabaseClient(
      AppEnviroment.url,
      AppEnviroment.anonKey,
    );

    try {
      final response = await tempClient.auth.signInWithPassword(
        email: email,
        password: password,
      );

      final userId = response.user?.id;
      if (userId == null) return false;

      final profile =
          await tempClient
              .from('perfiles')
              .select('rol')
              .eq('id', userId)
              .single();

      final role = profile['rol'] as String?;

      return switch (requiredRole) {
        AuthorizationRole.supervisor => role == 'supervisor',
        AuthorizationRole.admin => role == 'admin',
      };
    } on AuthException {
      return false;
    } catch (_) {
      return false;
    } finally {
      await tempClient.dispose();
    }
  }
}
