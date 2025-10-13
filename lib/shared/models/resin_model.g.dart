// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'resin_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ResinModel _$ResinModelFromJson(Map<String, dynamic> json) => ResinModel(
  id: (json['id_oftalmico'] as num).toInt(),
  description: json['descripcion'] as String?,
  design: json['diseño'] as String?,
  line: json['linea'] as String?,
  material: json['material'] as String?,
  technology: json['tecnologia'] as String?,
  text: json['texto'] as String?,
  quantity: (json['cantidad'] as num?)?.toInt(),
  price: (json['precio'] as num?)?.toDouble(),
  priceInternal: (json['precio_interno'] as num?)?.toDouble(),
);

Map<String, dynamic> _$ResinModelToJson(ResinModel instance) =>
    <String, dynamic>{
      'id_oftalmico': instance.id,
      'descripcion': instance.description,
      'diseño': instance.design,
      'linea': instance.line,
      'material': instance.material,
      'tecnologia': instance.technology,
      'texto': instance.text,
      'cantidad': instance.quantity,
      'precio': instance.price,
      'precio_interno': instance.priceInternal,
    };
