// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'row.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RowBean _$RowBeanFromJson(Map<String, dynamic> json) {
  return RowBean(
    uuid: json['uuid'] as String,
    values: (json['values'] as List<dynamic>).map((e) => e as Object).toList(),
    createdAt: json['created_at'] as int,
    updatedAt: json['updated_at'] as int,
    createdBy: json['created_by'] as String,
    updatedBy: json['updated_by'] as String,
  );
}

Map<String, dynamic> _$RowBeanToJson(RowBean instance) => <String, dynamic>{
      'uuid': instance.uuid,
      'created_at': instance.createdAt,
      'updated_at': instance.updatedAt,
      'created_by': instance.createdBy,
      'updated_by': instance.updatedBy,
      'values': instance.values,
    };
