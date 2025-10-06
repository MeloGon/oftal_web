import 'package:freezed_annotation/freezed_annotation.dart';

part 'patient_model.freezed.dart';
part 'patient_model.g.dart';

@freezed
@JsonSerializable()
class PatientModel with _$PatientModel {
  @override
  @JsonKey(name: 'ID PACIENTE', includeFromJson: true, includeToJson: true)
  final int id;
  @override
  @JsonKey(name: 'SUCURSAL', includeFromJson: true, includeToJson: true)
  final String branch;
  @override
  @JsonKey(
    name: 'FECHA DE REGISTRO',
    includeFromJson: true,
    includeToJson: true,
  )
  final String registerDate;
  @override
  @JsonKey(name: 'NOMBRE COMPLETO', includeFromJson: true, includeToJson: true)
  final String name;
  @override
  @JsonKey(
    name: 'FECHA DE NACIMIENTO',
    includeFromJson: true,
    includeToJson: true,
  )
  final String birthDate;
  @override
  @JsonKey(name: 'TELEFONO CEL', includeFromJson: true, includeToJson: true)
  final String phone;
  @override
  @JsonKey(name: 'OBSERVACIONES', includeFromJson: true, includeToJson: true)
  final String observations;
  @override
  @JsonKey(name: 'GENERO', includeFromJson: true, includeToJson: true)
  final String gender;
  @override
  @JsonKey(
    name: 'fecha_registro_actualizada',
    includeFromJson: true,
    includeToJson: true,
  )
  final String updatedRegisterDate;

  PatientModel({
    required this.id,
    required this.branch,
    required this.registerDate,
    required this.name,
    required this.birthDate,
    required this.phone,
    required this.observations,
    required this.gender,
    required this.updatedRegisterDate,
  });

  factory PatientModel.fromJson(Map<String, Object?> json) =>
      _$PatientModelFromJson(json);

  Map<String, dynamic> toJson() => _$PatientModelToJson(this);
}
