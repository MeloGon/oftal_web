import 'package:freezed_annotation/freezed_annotation.dart';

part 'sales_details_model.freezed.dart';
part 'sales_details_model.g.dart';

@freezed
@JsonSerializable()
class SalesDetailsModel with _$SalesDetailsModel {
  @override
  @JsonKey(name: 'ID', includeFromJson: true, includeToJson: true)
  final int? id;
  @override
  @JsonKey(name: 'ID REMISION', includeFromJson: true, includeToJson: true)
  final String? idRemision;
  @override
  @JsonKey(name: 'FOLIO DE VENTA', includeFromJson: true, includeToJson: true)
  final String? folioSale;
  @override
  @JsonKey(name: 'FECHA DE VENTA', includeFromJson: true, includeToJson: true)
  final String? dateSale;
  @override
  @JsonKey(name: 'PACIENTE', includeFromJson: true, includeToJson: true)
  final String? patient;
  @override
  @JsonKey(name: 'ID OFTALMICO', includeFromJson: true, includeToJson: true)
  final String? idOftalmico;
  @override
  @JsonKey(name: 'DESCRIPCION', includeFromJson: true, includeToJson: true)
  final String? description;
  @override
  @JsonKey(name: 'DISEÑO', includeFromJson: true, includeToJson: true)
  final String? design;
  @override
  @JsonKey(name: 'LINEA', includeFromJson: true, includeToJson: true)
  final String? line;
  @override
  @JsonKey(name: 'MATERIAL', includeFromJson: true, includeToJson: true)
  final String? material;
  @override
  @JsonKey(name: 'TECNOLOGIA', includeFromJson: true, includeToJson: true)
  final String? technology;
  @override
  @JsonKey(name: 'SERIE', includeFromJson: true, includeToJson: true)
  final String? serie;
  @override
  @JsonKey(name: 'TEXTO', includeFromJson: true, includeToJson: true)
  final String? text;
  @override
  @JsonKey(name: 'CANTIDAD', includeFromJson: true, includeToJson: true)
  final String? quantity;
  @override
  @JsonKey(name: 'PRECIO', includeFromJson: true, includeToJson: true)
  final double? price;
  @override
  @JsonKey(name: 'ID MONTURA', includeFromJson: true, includeToJson: true)
  final int? idMount;
  @override
  @JsonKey(name: 'MONTURA', includeFromJson: true, includeToJson: true)
  final String? mount;
  @override
  @JsonKey(name: 'MONTURA MARCA', includeFromJson: true, includeToJson: true)
  final String? mountBrand;
  @override
  @JsonKey(name: 'MONTURA MODELO', includeFromJson: true, includeToJson: true)
  final String? mountModel;
  @override
  @JsonKey(name: 'MONTURA COLOR', includeFromJson: true, includeToJson: true)
  final String? mountColor;
  @override
  @JsonKey(name: 'MONTURA CANTIDAD', includeFromJson: true, includeToJson: true)
  final String? mountQuantity;
  @override
  @JsonKey(name: 'MONTURA PRECIO', includeFromJson: true, includeToJson: true)
  final double? mountPrice;
  @override
  @JsonKey(name: 'MONTURA TEXTO', includeFromJson: true, includeToJson: true)
  final String? mountText;

  @override
  @JsonKey(
    name: 'fecha_ventas_actualizada',
    includeFromJson: true,
    includeToJson: true,
  )
  final String? updatedDate;

  SalesDetailsModel({
    this.id,
    this.idRemision,
    this.dateSale,
    this.patient,
    this.description,
    this.design,
    this.line,
    this.material,
    this.technology,
    this.serie,
    this.text,
    this.quantity,
    this.price,
    this.mount,
    this.mountBrand,
    this.mountModel,
    this.mountQuantity,
    this.mountPrice,
    this.mountText,
    this.updatedDate,
    this.folioSale,
    this.idOftalmico,
    this.idMount,
    this.mountColor,
  });

  factory SalesDetailsModel.fromJson(Map<String, Object?> json) =>
      _$SalesDetailsModelFromJson(json);

  Map<String, dynamic> toJson() => _$SalesDetailsModelToJson(this);
}
