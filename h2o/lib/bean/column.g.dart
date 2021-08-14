// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'column.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ColumnBean _$ColumnBeanFromJson(Map<String, dynamic> json) {
  return ColumnBean(
    uuid: json['uuid'] as String,
    name: json['name'] as String,
    type: json['type'] as String,
    defaultValue: json['default_value'] as String,
    tableId: json['table_id'] as String,
    createdAt: json['created_at'] as int,
    updatedAt: json['updated_at'] as int,
  );
}

Map<String, dynamic> _$ColumnBeanToJson(ColumnBean instance) =>
    <String, dynamic>{
      'uuid': instance.uuid,
      'name': instance.name,
      'type': instance.type,
      'default_value': instance.defaultValue,
      'table_id': instance.tableId,
      'created_at': instance.createdAt,
      'updated_at': instance.updatedAt,
    };
