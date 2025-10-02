import 'package:freezed_annotation/freezed_annotation.dart';

part 'profile_model.freezed.dart';
part 'profile_model.g.dart';

@freezed
@JsonSerializable()
class ProfileModel with _$ProfileModel {
  @override
  @JsonKey(name: 'id', includeFromJson: true, includeToJson: true)
  final String? id;

  @override
  @JsonKey(name: 'nombre', includeFromJson: true, includeToJson: true)
  final String? name;

  @override
  @JsonKey(name: 'sucursal', includeFromJson: true, includeToJson: true)
  final String? branchName;

  @override
  @JsonKey(name: 'rol', includeFromJson: true, includeToJson: true)
  final String? role;

  ProfileModel({
    this.id,
    this.name,
    this.branchName,
    this.role,
  });

  factory ProfileModel.fromJson(Map<String, Object?> json) =>
      _$ProfileModelFromJson(json);

  Map<String, dynamic> toJson() => _$ProfileModelToJson(this);
}
