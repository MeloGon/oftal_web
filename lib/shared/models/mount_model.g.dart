// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mount_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MountModel _$MountModelFromJson(Map<String, dynamic> json) => MountModel(
  id: (json['ID ARMAZON'] as num).toInt(),
  brand: json['MARCA'] as String,
  model: json['MODELO'] as String,
  color: json['COLOR'] as String,
  description: json['DESCRIPCION'] as String,
  price: (json['PRECIO'] as num).toDouble(),
  opticName: json['NOMBRE DE LA OPTICA'] as String,
  barcode: json['CODIGO DE BARRAS'] as String,
  stock: (json['EXISTENCIAS'] as num).toInt(),
);

Map<String, dynamic> _$MountModelToJson(MountModel instance) =>
    <String, dynamic>{
      'ID ARMAZON': instance.id,
      'MARCA': instance.brand,
      'MODELO': instance.model,
      'COLOR': instance.color,
      'DESCRIPCION': instance.description,
      'PRECIO': instance.price,
      'NOMBRE DE LA OPTICA': instance.opticName,
      'CODIGO DE BARRAS': instance.barcode,
      'EXISTENCIAS': instance.stock,
    };
