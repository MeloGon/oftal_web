import 'package:freezed_annotation/freezed_annotation.dart';

part 'seller_model.freezed.dart';
part 'seller_model.g.dart';

@freezed
@JsonSerializable()
class SellerModel with _$SellerModel {
  @override
  @JsonKey(name: 'id', includeFromJson: true, includeToJson: true)
  final int id;
  @override
  @JsonKey(name: 'NOMBRE', includeFromJson: true, includeToJson: true)
  final String name;

  SellerModel({
    required this.id,
    required this.name,
  });

  factory SellerModel.fromJson(Map<String, Object?> json) =>
      _$SellerModelFromJson(json);

  Map<String, dynamic> toJson() => _$SellerModelToJson(this);
}
