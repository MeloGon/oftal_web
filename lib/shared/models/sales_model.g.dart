// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sales_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SalesModel _$SalesModelFromJson(Map<String, dynamic> json) => SalesModel(
  id: (json['ID REMISION'] as num).toInt(),
  branch: json['SUCURSAL'] as String?,
  date: json['FECHA'] as String?,
  patient: json['PACIENTE'] as String?,
  authorName: json['AUTOR NOMBRE'] as String?,
  total: (json['TOTAL'] as num?)?.toDouble(),
  discount: (json['DESCUENTO'] as num?)?.toDouble(),
  totalWithDiscount: (json['TOTAL CON DESCUENTO'] as num?)?.toDouble(),
  account: (json['A CUENTA'] as num?)?.toDouble(),
  rest: (json['RESTA'] as num?)?.toDouble(),
  folioSale: json['FOLIO REMISION'] as String?,
);

Map<String, dynamic> _$SalesModelToJson(SalesModel instance) =>
    <String, dynamic>{
      'ID REMISION': instance.id,
      'SUCURSAL': instance.branch,
      'FECHA': instance.date,
      'PACIENTE': instance.patient,
      'AUTOR NOMBRE': instance.authorName,
      'TOTAL': instance.total,
      'DESCUENTO': instance.discount,
      'TOTAL CON DESCUENTO': instance.totalWithDiscount,
      'A CUENTA': instance.account,
      'RESTA': instance.rest,
      'FOLIO REMISION': instance.folioSale,
    };
