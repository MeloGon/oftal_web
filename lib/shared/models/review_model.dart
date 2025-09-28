import 'package:freezed_annotation/freezed_annotation.dart';

part 'review_model.freezed.dart';
part 'review_model.g.dart';

@freezed
@JsonSerializable()
class ReviewModel with _$ReviewModel {
  @override
  @JsonKey(name: 'ID REFRACCION', includeFromJson: true, includeToJson: true)
  final int idReview;
  @override
  @JsonKey(name: 'PACIENTE', includeFromJson: true, includeToJson: true)
  final String? patientName;
  @override
  @JsonKey(name: 'FECHA', includeFromJson: true, includeToJson: true)
  final String? date;
  @override
  @JsonKey(
    name: 'MOTIVO DE CONSULTA',
    includeFromJson: true,
    includeToJson: true,
    includeIfNull: true,
  )
  final String? reasonConsult;
  @override
  @JsonKey(name: 'HISTORIA CLINICA', includeFromJson: true, includeToJson: true)
  final String? clinicHistory;
  @override
  @JsonKey(name: 'OD ESF', includeFromJson: true, includeToJson: true)
  final String? odEsf;
  @override
  @JsonKey(name: 'OD CIL', includeFromJson: true, includeToJson: true)
  final String? odCil;
  @override
  @JsonKey(name: 'OD EJE', includeFromJson: true, includeToJson: true)
  final String? odEje;
  @override
  @JsonKey(name: 'OD AV', includeFromJson: true, includeToJson: true)
  final String? odAv;
  @override
  @JsonKey(name: 'OI ESF', includeFromJson: true, includeToJson: true)
  final String? oiEsf;
  @override
  @JsonKey(name: 'OI CIL', includeFromJson: true, includeToJson: true)
  final String? oiCil;
  @override
  @JsonKey(name: 'OI EJE', includeFromJson: true, includeToJson: true)
  final String? oiEje;
  @override
  @JsonKey(name: 'OI AV', includeFromJson: true, includeToJson: true)
  final String? oiAv;
  @override
  @JsonKey(name: 'ADD', includeFromJson: true, includeToJson: true)
  final String? add;
  @override
  @JsonKey(name: 'OBSERVACIONES', includeFromJson: true, includeToJson: true)
  final String? observation;
  @override
  @JsonKey(name: 'DIP', includeFromJson: true, includeToJson: true)
  final String? dip;
  @override
  @JsonKey(name: 'SUCURSAL', includeFromJson: true, includeToJson: true)
  final String? branchName;
  @override
  @JsonKey(name: 'OD CB LC', includeFromJson: true, includeToJson: true)
  final String? odCbLc;
  @override
  @JsonKey(name: 'OD DIAM LC', includeFromJson: true, includeToJson: true)
  final String? odDiamLc;
  @override
  @JsonKey(name: 'OI CB LC', includeFromJson: true, includeToJson: true)
  final String? oiCbLc;
  @override
  @JsonKey(name: 'OI DIAM LC', includeFromJson: true, includeToJson: true)
  final String? oiDiamLc;
  @override
  @JsonKey(
    name: 'TIPO DE GRADUACION',
    includeFromJson: true,
    includeToJson: true,
  )
  final String? graduationType;
  @override
  @JsonKey(
    name: 'AV SIN RX OD LEJOS',
    includeFromJson: true,
    includeToJson: true,
  )
  final String? avSinRxOdLejos;
  @override
  @JsonKey(
    name: 'AV SIN RX OI LEJOS',
    includeFromJson: true,
    includeToJson: true,
  )
  final String? avSinRxOiLejos;
  @override
  @JsonKey(name: 'CV OD LEJOS', includeFromJson: true, includeToJson: true)
  final String? cvOdLejos;
  @override
  @JsonKey(name: 'CV OI LEJOS', includeFromJson: true, includeToJson: true)
  final String? cvOiLejos;
  @override
  @JsonKey(
    name: 'AV SIN RX OD CERCA',
    includeFromJson: true,
    includeToJson: true,
  )
  final String? avSinRxOdCerca;
  @override
  @JsonKey(
    name: 'AV SIN RX OI CERCA',
    includeFromJson: true,
    includeToJson: true,
  )
  final String? avSinRxOiCerca;
  @override
  @JsonKey(
    name: 'AV CON RX OD CERCA',
    includeFromJson: true,
    includeToJson: true,
  )
  final String? avConRxOdCerca;
  @override
  @JsonKey(
    name: 'AV CON RX OI CERCA',
    includeFromJson: true,
    includeToJson: true,
  )
  final String? avConRxOiCerca;
  @override
  @JsonKey(
    name: 'DIAGNOSTICO OPTOMETRICO',
    includeFromJson: true,
    includeToJson: true,
  )
  final String? optometricDiagnosis;

  ReviewModel({
    required this.idReview,
    this.patientName,
    this.date,
    this.reasonConsult,
    this.clinicHistory,
    this.odEsf,
    this.odCil,
    this.odEje,
    this.odAv,
    this.oiEsf,
    this.oiCil,
    this.oiEje,
    this.oiAv,
    this.add,
    this.observation,
    this.dip,
    this.branchName,
    this.odCbLc,
    this.odDiamLc,
    this.oiCbLc,
    this.oiDiamLc,
    this.graduationType,
    this.avSinRxOdLejos,
    this.avSinRxOiLejos,
    this.cvOdLejos,
    this.cvOiLejos,
    this.avSinRxOdCerca,
    this.avSinRxOiCerca,
    this.avConRxOdCerca,
    this.avConRxOiCerca,
    this.optometricDiagnosis,
  });

  factory ReviewModel.fromJson(Map<String, Object?> json) =>
      _$ReviewModelFromJson(json);

  Map<String, dynamic> toJson() => _$ReviewModelToJson(this);
}
