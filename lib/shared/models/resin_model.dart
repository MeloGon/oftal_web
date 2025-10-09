import 'package:freezed_annotation/freezed_annotation.dart';

part 'resin_model.freezed.dart';
part 'resin_model.g.dart';

@freezed
@JsonSerializable()
class ResinModel with _$ResinModel {
  @override
  @JsonKey(name: 'id_oftalmico', includeFromJson: true, includeToJson: true)
  final int id;
  @override
  @JsonKey(name: 'descripcion', includeFromJson: true, includeToJson: true)
  final String? description;
  @override
  @JsonKey(name: 'diseño', includeFromJson: true, includeToJson: true)
  final String? design;
  @override
  @JsonKey(name: 'linea', includeFromJson: true, includeToJson: true)
  final String? line;
  @override
  @JsonKey(name: 'material', includeFromJson: true, includeToJson: true)
  final String? material;
  @override
  @JsonKey(name: 'tecnologia', includeFromJson: true, includeToJson: true)
  final String? technology;
  @override
  @JsonKey(name: 'texto', includeFromJson: true, includeToJson: true)
  final String? text;
  @override
  @JsonKey(name: 'cantidad', includeFromJson: true, includeToJson: true)
  final int? quantity;
  @override
  @JsonKey(name: 'precio', includeFromJson: true, includeToJson: true)
  final double? price;

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
  });

  factory ResinModel.fromJson(Map<String, Object?> json) =>
      _$ResinModelFromJson(json);

  Map<String, dynamic> toJson() => _$ResinModelToJson(this);
}
