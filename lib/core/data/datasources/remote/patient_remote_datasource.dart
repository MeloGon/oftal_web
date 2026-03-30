import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:oftal_web/shared/models/shared_models.dart';

abstract class PatientRemoteDataSource {
  Future<List<PatientModel>> searchPatients(String query);
  Future<List<PatientModel>> getLastPatients({int limit = 5});
  Future<int> countByBranch(String branch);
  Future<void> insertPatient(PatientModel patient);
  Future<void> deletePatient(int id);
}

class PatientRemoteDataSourceImpl implements PatientRemoteDataSource {
  final SupabaseClient client;
  PatientRemoteDataSourceImpl(this.client);

  @override
  Future<List<PatientModel>> searchPatients(String query) async {
    final response = await client
        .from('pacientes')
        .select()
        .textSearch('"NOMBRE COMPLETO"', '%$query%', type: TextSearchType.plain);
    return response.map((json) => PatientModel.fromJson(json)).toList();
  }

  @override
  Future<List<PatientModel>> getLastPatients({int limit = 5}) async {
    final response = await client
        .from('pacientes')
        .select()
        .limit(limit)
        .order('fecha_registro_actualizada', ascending: false);
    return response.map((json) => PatientModel.fromJson(json)).toList();
  }

  @override
  Future<int> countByBranch(String branch) async {
    final response = await client
        .from('pacientes')
        .select('*')
        .eq('"SUCURSAL"', branch)
        .count();
    return response.count;
  }

  @override
  Future<void> insertPatient(PatientModel patient) async {
    await client.from('pacientes').insert(patient.toJson()).select();
  }

  @override
  Future<void> deletePatient(int id) async {
    await client.from('pacientes').delete().eq('ID PACIENTE', id);
  }
}
