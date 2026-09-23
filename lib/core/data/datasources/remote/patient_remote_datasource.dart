import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:oftal_web/shared/models/shared_models.dart';

abstract class PatientRemoteDataSource {
  Future<List<PatientModel>> searchPatients(String query);
  Future<({List<PatientModel> items, bool hasMore})> searchPatientsPage({
    String query = '',
    int offset = 0,
    int limit = 10,
  });
  Future<List<PatientModel>> getLastPatients({int limit = 5});
  Future<int> countByBranch(String branch);
  Future<void> insertPatient(PatientModel patient);
  Future<void> deletePatient(int id);
  Future<void> updatePatient(PatientModel patient);
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
  Future<({List<PatientModel> items, bool hasMore})> searchPatientsPage({
    String query = '',
    int offset = 0,
    int limit = 10,
  }) async {
    var q = client.from('pacientes').select();
    if (query.isNotEmpty) {
      q = q.textSearch(
        '"NOMBRE COMPLETO"',
        '%$query%',
        type: TextSearchType.plain,
      );
    }
    final response = await q
        .order('fecha_registro_actualizada', ascending: false)
        .range(offset, offset + limit);
    final rows = response.map((json) => PatientModel.fromJson(json)).toList();
    final hasMore = rows.length > limit;
    return (
      items: hasMore ? rows.sublist(0, limit) : rows,
      hasMore: hasMore,
    );
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

  @override
  Future<void> updatePatient(PatientModel patient) async {
    await client.from('pacientes').update({
      'NOMBRE COMPLETO': patient.name,
      'TELEFONO CEL': patient.phone,
      'GENERO': patient.gender,
      'FECHA DE NACIMIENTO': patient.birthDate,
      'SUCURSAL': patient.branch,
      'OBSERVACIONES': patient.observations,
    }).eq('ID PACIENTE', patient.id);
  }
}
