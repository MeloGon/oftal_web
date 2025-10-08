import 'package:freezed_annotation/freezed_annotation.dart';

part 'sales_model.freezed.dart';
part 'sales_model.g.dart';

@freezed
@JsonSerializable()
class SalesModel with _$SalesModel {
  @override
  @JsonKey(name: 'ID REMISION', includeFromJson: true, includeToJson: true)
  final int id;
  @override
  @JsonKey(name: 'SUCURSAL', includeFromJson: true, includeToJson: true)
  final String? branch;
  @override
  @JsonKey(name: 'FECHA', includeFromJson: true, includeToJson: true)
  final String? date;
  @override
  @JsonKey(name: 'PACIENTE', includeFromJson: true, includeToJson: true)
  final String? patient;
  @override
  @JsonKey(name: 'AUTOR NOMBRE', includeFromJson: true, includeToJson: true)
  final String? authorName;
  @override
  @JsonKey(name: 'TOTAL', includeFromJson: true, includeToJson: true)
  final double? total;
  @override
  @JsonKey(name: 'DESCUENTO', includeFromJson: true, includeToJson: true)
  final double? discount;
  @override
  @JsonKey(
    name: 'TOTAL CON DESCUENTO',
    includeFromJson: true,
    includeToJson: true,
  )
  final double? totalWithDiscount;
  @override
  @JsonKey(name: 'A CUENTA', includeFromJson: true, includeToJson: true)
  final double? account;
  @override
  @JsonKey(name: 'RESTA', includeFromJson: true, includeToJson: true)
  final double? rest;
  @override
  @JsonKey(name: 'FOLIO REMISION', includeFromJson: true, includeToJson: true)
  final String? folioSale;
  @override
  @JsonKey(
    name: 'fecha_actualizada',
    includeFromJson: true,
    includeToJson: true,
  )
  final String? updatedDate;

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
  });

  factory SalesModel.fromJson(Map<String, Object?> json) =>
      _$SalesModelFromJson(json);

  Map<String, dynamic> toJson() => _$SalesModelToJson(this);

  static SalesModel empty() => SalesModel(
    id: 0,
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
  );
}
