import 'package:freezed_annotation/freezed_annotation.dart';

part 'mount_model.freezed.dart';
part 'mount_model.g.dart';

@freezed
@JsonSerializable()
class MountModel with _$MountModel {
  @override
  @JsonKey(name: 'ID ARMAZON', includeFromJson: true, includeToJson: true)
  final int id;
  @override
  @JsonKey(name: 'MARCA', includeFromJson: true, includeToJson: true)
  final String brand;
  @override
  @JsonKey(name: 'MODELO', includeFromJson: true, includeToJson: true)
  final String model;
  @override
  @JsonKey(name: 'COLOR', includeFromJson: true, includeToJson: true)
  final String color;
  @override
  @JsonKey(name: 'DESCRIPCION', includeFromJson: true, includeToJson: true)
  final String description;
  @override
  @JsonKey(name: 'PRECIO', includeFromJson: true, includeToJson: true)
  final double price;
  @override
  @JsonKey(
    name: 'NOMBRE DE LA OPTICA',
    includeFromJson: true,
    includeToJson: true,
  )
  final String opticName;
  @override
  @JsonKey(name: 'CODIGO DE BARRAS', includeFromJson: true, includeToJson: true)
  final String barcode;
  @override
  @JsonKey(name: 'EXISTENCIAS', includeFromJson: true, includeToJson: true)
  final int stock;

  MountModel({
    required this.id,
    required this.brand,
    required this.model,
    required this.color,
    required this.description,
    required this.price,
    required this.opticName,
    required this.barcode,
    required this.stock,
  });

  factory MountModel.fromJson(Map<String, Object?> json) =>
      _$MountModelFromJson(json);

  Map<String, dynamic> toJson() => _$MountModelToJson(this);
}
