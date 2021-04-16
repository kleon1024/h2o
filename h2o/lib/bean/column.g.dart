// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'column.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ColumnBean _$ColumnBeanFromJson(Map<String, dynamic> json) {
  return ColumnBean(
    id: json['id'] as String,
    name: json['name'] as String,
    type: json['type'] as String,
    defaultValue: json['defaultValue'] as String,
  );
}

Map<String, dynamic> _$ColumnBeanToJson(ColumnBean instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'type': instance.type,
      'defaultValue': instance.defaultValue,
    };
