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
  @JsonKey(name: 'NOMBRE COMPLETO', includeFromJson: true, includeToJson: true)
  final String name;

  PatientModel({
    required this.id,
    required this.name,
  });

  factory PatientModel.fromJson(Map<String, Object?> json) =>
      _$PatientModelFromJson(json);

  Map<String, dynamic> toJson() => _$PatientModelToJson(this);
}
