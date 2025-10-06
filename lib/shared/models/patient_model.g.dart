// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'patient_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PatientModel _$PatientModelFromJson(Map<String, dynamic> json) => PatientModel(
  id: (json['ID PACIENTE'] as num).toInt(),
  branch: json['SUCURSAL'] as String,
  registerDate: json['FECHA DE REGISTRO'] as String,
  name: json['NOMBRE COMPLETO'] as String,
  birthDate: json['FECHA DE NACIMIENTO'] as String,
  phone: json['TELEFONO CEL'] as String,
  gender: json['GENERO'] as String,
  updatedRegisterDate: json['fecha_registro_actualizada'] as String,
);

Map<String, dynamic> _$PatientModelToJson(PatientModel instance) =>
    <String, dynamic>{
      'ID PACIENTE': instance.id,
      'SUCURSAL': instance.branch,
      'FECHA DE REGISTRO': instance.registerDate,
      'NOMBRE COMPLETO': instance.name,
      'FECHA DE NACIMIENTO': instance.birthDate,
      'TELEFONO CEL': instance.phone,
      'GENERO': instance.gender,
      'fecha_registro_actualizada': instance.updatedRegisterDate,
    };
