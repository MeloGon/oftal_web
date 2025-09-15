// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'patient_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PatientModel _$PatientModelFromJson(Map<String, dynamic> json) => PatientModel(
  id: (json['ID PACIENTE'] as num).toInt(),
  name: json['NOMBRE COMPLETO'] as String,
);

Map<String, dynamic> _$PatientModelToJson(PatientModel instance) =>
    <String, dynamic>{
      'ID PACIENTE': instance.id,
      'NOMBRE COMPLETO': instance.name,
    };
