import 'package:freezed_annotation/freezed_annotation.dart';

part 'resin_model.freezed.dart';
part 'resin_model.g.dart';

@freezed
@JsonSerializable()
class ResinModel with _$ResinModel {
  @JsonKey(name: 'id_oftalmico', includeFromJson: true, includeToJson: true)
  final int id;
  @JsonKey(name: 'descripcion', includeFromJson: true, includeToJson: true)
  final String? description;
  @JsonKey(name: 'diseño', includeFromJson: true, includeToJson: true)
  final String? design;
  @JsonKey(name: 'linea', includeFromJson: true, includeToJson: true)
  final String? line;
  @JsonKey(name: 'material', includeFromJson: true, includeToJson: true)
  final String? material;
  @JsonKey(name: 'tecnologia', includeFromJson: true, includeToJson: true)
  final String? technology;
  @JsonKey(name: 'texto', includeFromJson: true, includeToJson: true)
  final String? text;
  @JsonKey(name: 'cantidad', includeFromJson: true, includeToJson: true)
  final int? quantity;
  @JsonKey(name: 'precio', includeFromJson: true, includeToJson: true)
  final double? price;
  @JsonKey(name: 'precio_interno', includeFromJson: true, includeToJson: true)
  final double? priceInternal;

  ResinModel({
    required this.id,
    required this.description,
    required this.design,
    required this.line,
    required this.material,
    required this.technology,
    required this.text,
    required this.quantity,
    required this.price,
    required this.priceInternal,
  });

  factory ResinModel.fromJson(Map<String, Object?> json) =>
      _$ResinModelFromJson(json);

  Map<String, dynamic> toJson() => _$ResinModelToJson(this);
}
