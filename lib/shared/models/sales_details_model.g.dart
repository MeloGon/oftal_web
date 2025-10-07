// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sales_details_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SalesDetailsModel _$SalesDetailsModelFromJson(Map<String, dynamic> json) =>
    SalesDetailsModel(
      id: (json['ID'] as num?)?.toInt(),
      idRemision: json['ID REMISION'] as String?,
      dateSale: json['FECHA DE VENTA'] as String?,
      patient: json['PACIENTE'] as String?,
      description: json['DESCRIPCION'] as String?,
      design: json['DISEÑO'] as String?,
      line: json['LINEA'] as String?,
      material: json['MATERIAL'] as String?,
      technology: json['TECNOLOGIA'] as String?,
      serie: json['SERIE'] as String?,
      text: json['TEXTO'] as String?,
      quantity: json['CANTIDAD'] as String?,
      price: (json['PRECIO'] as num?)?.toDouble(),
      mount: json['MONTURA'] as String?,
      mountBrand: json['MONTURA MARCA'] as String?,
      mountModel: json['MONTURA MODELO'] as String?,
      mountQuantity: json['MONTURA CANTIDAD'] as String?,
      mountPrice: (json['MONTURA PRECIO'] as num?)?.toDouble(),
      mountText: json['MONTURA TEXTO'] as String?,
      updatedDate: json['fecha_ventas_actualizada'] as String?,
    );

Map<String, dynamic> _$SalesDetailsModelToJson(SalesDetailsModel instance) =>
    <String, dynamic>{
      'ID': instance.id,
      'ID REMISION': instance.idRemision,
      'FECHA DE VENTA': instance.dateSale,
      'PACIENTE': instance.patient,
      'DESCRIPCION': instance.description,
      'DISEÑO': instance.design,
      'LINEA': instance.line,
      'MATERIAL': instance.material,
      'TECNOLOGIA': instance.technology,
      'SERIE': instance.serie,
      'TEXTO': instance.text,
      'CANTIDAD': instance.quantity,
      'PRECIO': instance.price,
      'MONTURA': instance.mount,
      'MONTURA MARCA': instance.mountBrand,
      'MONTURA MODELO': instance.mountModel,
      'MONTURA CANTIDAD': instance.mountQuantity,
      'MONTURA PRECIO': instance.mountPrice,
      'MONTURA TEXTO': instance.mountText,
      'fecha_ventas_actualizada': instance.updatedDate,
    };
