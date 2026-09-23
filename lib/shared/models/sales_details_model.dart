import 'package:freezed_annotation/freezed_annotation.dart';

part 'sales_details_model.freezed.dart';
part 'sales_details_model.g.dart';

@freezed
@JsonSerializable()
class SalesDetailsModel with _$SalesDetailsModel {
  @JsonKey(name: 'ID', includeFromJson: true, includeToJson: true)
  final int? id;
  @JsonKey(name: 'ID REMISION', includeFromJson: true, includeToJson: true)
  final String? idRemision;
  @JsonKey(name: 'FOLIO DE VENTA', includeFromJson: true, includeToJson: true)
  final String? folioSale;
  @JsonKey(name: 'FECHA DE VENTA', includeFromJson: true, includeToJson: true)
  final String? dateSale;
  @JsonKey(name: 'PACIENTE', includeFromJson: true, includeToJson: true)
  final String? patient;
  @JsonKey(name: 'ID OFTALMICO', includeFromJson: true, includeToJson: true)
  final int? idOftalmico;
  @JsonKey(name: 'DESCRIPCION', includeFromJson: true, includeToJson: true)
  final String? description;
  @JsonKey(name: 'DISEÑO', includeFromJson: true, includeToJson: true)
  final String? design;
  @JsonKey(name: 'LINEA', includeFromJson: true, includeToJson: true)
  final String? line;
  @JsonKey(name: 'MATERIAL', includeFromJson: true, includeToJson: true)
  final String? material;
  @JsonKey(name: 'TECNOLOGIA', includeFromJson: true, includeToJson: true)
  final String? technology;
  @JsonKey(name: 'SERIE', includeFromJson: true, includeToJson: true)
  final String? serie;
  @JsonKey(name: 'TEXTO', includeFromJson: true, includeToJson: true)
  final String? text;
  @JsonKey(name: 'CANTIDAD', includeFromJson: true, includeToJson: true)
  final String? quantity;
  @JsonKey(name: 'PRECIO', includeFromJson: true, includeToJson: true)
  final double? price;
  @JsonKey(name: 'ID MONTURA', includeFromJson: true, includeToJson: true)
  final int? idMount;
  @JsonKey(name: 'MONTURA', includeFromJson: true, includeToJson: true)
  final String? mount;
  @JsonKey(name: 'MONTURA MARCA', includeFromJson: true, includeToJson: true)
  final String? mountBrand;
  @JsonKey(name: 'MONTURA MODELO', includeFromJson: true, includeToJson: true)
  final String? mountModel;
  @JsonKey(name: 'MONTURA COLOR', includeFromJson: true, includeToJson: true)
  final String? mountColor;
  @JsonKey(name: 'MONTURA CANTIDAD', includeFromJson: true, includeToJson: true)
  final String? mountQuantity;
  @JsonKey(name: 'MONTURA PRECIO', includeFromJson: true, includeToJson: true)
  final double? mountPrice;
  @JsonKey(name: 'MONTURA TEXTO', includeFromJson: true, includeToJson: true)
  final String? mountText;

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
