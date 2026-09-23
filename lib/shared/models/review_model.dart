import 'package:freezed_annotation/freezed_annotation.dart';

part 'review_model.freezed.dart';
part 'review_model.g.dart';

@freezed
@JsonSerializable()
class ReviewModel with _$ReviewModel {
  @JsonKey(name: 'ID REFRACCION', includeFromJson: true, includeToJson: true)
  final int idReview;
  @JsonKey(name: 'PACIENTE', includeFromJson: true, includeToJson: true)
  final String? patientName;
  @JsonKey(name: 'FECHA', includeFromJson: true, includeToJson: true)
  final String? date;
  @JsonKey(
    name: 'MOTIVO DE CONSULTA',
    includeFromJson: true,
    includeToJson: true,
    includeIfNull: true,
  )
  final String? reasonConsult;
  @JsonKey(name: 'HISTORIA CLINICA', includeFromJson: true, includeToJson: true)
  final String? clinicHistory;
  @JsonKey(name: 'OD ESF', includeFromJson: true, includeToJson: true)
  final String? odEsf;
  @JsonKey(name: 'OD CIL', includeFromJson: true, includeToJson: true)
  final String? odCil;
  @JsonKey(name: 'OD EJE', includeFromJson: true, includeToJson: true)
  final String? odEje;
  @JsonKey(name: 'OD AV', includeFromJson: true, includeToJson: true)
  final String? odAv;
  @JsonKey(name: 'OI ESF', includeFromJson: true, includeToJson: true)
  final String? oiEsf;
  @JsonKey(name: 'OI CIL', includeFromJson: true, includeToJson: true)
  final String? oiCil;
  @JsonKey(name: 'OI EJE', includeFromJson: true, includeToJson: true)
  final String? oiEje;
  @JsonKey(name: 'OI AV', includeFromJson: true, includeToJson: true)
  final String? oiAv;
  @JsonKey(name: 'ADD', includeFromJson: true, includeToJson: true)
  final String? add;
  @JsonKey(name: 'OBSERVACIONES', includeFromJson: true, includeToJson: true)
  final String? observation;
  @JsonKey(name: 'DIP', includeFromJson: true, includeToJson: true)
  final String? dip;
  @JsonKey(name: 'SUCURSAL', includeFromJson: true, includeToJson: true)
  final String? branchName;
  @JsonKey(name: 'OD CB LC', includeFromJson: true, includeToJson: true)
  final String? odCbLc;
  @JsonKey(name: 'OD DIAM LC', includeFromJson: true, includeToJson: true)
  final String? odDiamLc;
  @JsonKey(name: 'OI CB LC', includeFromJson: true, includeToJson: true)
  final String? oiCbLc;
  @JsonKey(name: 'OI DIAM LC', includeFromJson: true, includeToJson: true)
  final String? oiDiamLc;
  @JsonKey(
    name: 'TIPO DE GRADUACION',
    includeFromJson: true,
    includeToJson: true,
  )
  final String? graduationType;
  @JsonKey(
    name: 'AV SIN RX OD LEJOS',
    includeFromJson: true,
    includeToJson: true,
  )
  final String? avSinRxOdLejos;
  @JsonKey(
    name: 'AV SIN RX OI LEJOS',
    includeFromJson: true,
    includeToJson: true,
  )
  final String? avSinRxOiLejos;
  @JsonKey(name: 'CV OD LEJOS', includeFromJson: true, includeToJson: true)
  final String? cvOdLejos;
  @JsonKey(name: 'CV OI LEJOS', includeFromJson: true, includeToJson: true)
  final String? cvOiLejos;
  @JsonKey(
    name: 'AV SIN RX OD CERCA',
    includeFromJson: true,
    includeToJson: true,
  )
  final String? avSinRxOdCerca;
  @JsonKey(
    name: 'AV SIN RX OI CERCA',
    includeFromJson: true,
    includeToJson: true,
  )
  final String? avSinRxOiCerca;
  @JsonKey(
    name: 'AV CON RX OD CERCA',
    includeFromJson: true,
    includeToJson: true,
  )
  final String? avConRxOdCerca;
  @JsonKey(
    name: 'AV CON RX OI CERCA',
    includeFromJson: true,
    includeToJson: true,
  )
  final String? avConRxOiCerca;
  @JsonKey(
    name: 'DIAGNOSTICO OPTOMETRICO',
    includeFromJson: true,
    includeToJson: true,
  )
  final String? optometricDiagnosis;
  @JsonKey(
    name: 'fecha_revision_actualizada',
    includeFromJson: true,
    includeToJson: true,
  )
  final String? dateReviewUpdated;

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
    this.dateReviewUpdated,
  });

  factory ReviewModel.fromJson(Map<String, Object?> json) =>
      _$ReviewModelFromJson(json);

  Map<String, dynamic> toJson() => _$ReviewModelToJson(this);
}
