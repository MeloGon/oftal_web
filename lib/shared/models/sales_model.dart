import 'package:freezed_annotation/freezed_annotation.dart';

part 'sales_model.freezed.dart';
part 'sales_model.g.dart';

@freezed
@JsonSerializable()
class SalesModel with _$SalesModel {
  @JsonKey(name: 'ID REMISION', includeFromJson: true, includeToJson: true)
  final String? id;
  @JsonKey(name: 'SUCURSAL', includeFromJson: true, includeToJson: true)
  final String? branch;
  @JsonKey(name: 'FECHA', includeFromJson: true, includeToJson: true)
  final String? date;
  @JsonKey(name: 'PACIENTE', includeFromJson: true, includeToJson: true)
  final String? patient;
  @JsonKey(name: 'AUTOR NOMBRE', includeFromJson: true, includeToJson: true)
  final String? authorName;
  @JsonKey(name: 'TOTAL', includeFromJson: true, includeToJson: true)
  final double? total;
  @JsonKey(name: 'DESCUENTO', includeFromJson: true, includeToJson: true)
  final double? discount;
  @JsonKey(
    name: 'TOTAL CON DESCUENTO',
    includeFromJson: true,
    includeToJson: true,
  )
  final double? totalWithDiscount;
  @JsonKey(name: 'A CUENTA', includeFromJson: true, includeToJson: true)
  final double? account;
  @JsonKey(name: 'RESTA', includeFromJson: true, includeToJson: true)
  final double? rest;
  @JsonKey(name: 'FOLIO REMISION', includeFromJson: true, includeToJson: true)
  final String? folioSale;
  @JsonKey(
    name: 'fecha_actualizada',
    includeFromJson: true,
    includeToJson: true,
  )
  final String? updatedDate;
  @JsonKey(
    name: 'fecha_venta_iso',
    includeFromJson: true,
    includeToJson: true,
  )
  final String? fechaVentaIso;

  SalesModel({
    required this.id,
    required this.branch,
    required this.date,
    required this.patient,
    required this.authorName,
    required this.total,
    required this.discount,
    required this.totalWithDiscount,
    required this.account,
    required this.rest,
    required this.folioSale,
    required this.updatedDate,
    this.fechaVentaIso,
  });

  factory SalesModel.fromJson(Map<String, Object?> json) =>
      _$SalesModelFromJson(json);

  Map<String, dynamic> toJson() => _$SalesModelToJson(this);

  static SalesModel empty() => SalesModel(
    id: '',
    branch: '',
    date: '',
    patient: '',
    authorName: '',
    total: 0,
    discount: 0,
    totalWithDiscount: 0,
    account: 0,
    rest: 0,
    folioSale: '',
    updatedDate: '',
    fechaVentaIso: '',
  );
}
