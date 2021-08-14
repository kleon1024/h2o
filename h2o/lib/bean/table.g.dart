// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'table.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TableBean _$TableBeanFromJson(Map<String, dynamic> json) {
  return TableBean(
    uuid: json['uuid'] as String,
    nodeId: json['node_id'] as String,
    createdAt: json['created_at'] as int,
    updatedAt: json['updated_at'] as int,
    columns: (json['columns'] as List<dynamic>)
        .map((e) => ColumnBean.fromJson(e as Map<String, dynamic>))
        .toList(),
  );
}

Map<String, dynamic> _$TableBeanToJson(TableBean instance) => <String, dynamic>{
      'uuid': instance.uuid,
      'node_id': instance.nodeId,
      'created_at': instance.createdAt,
      'updated_at': instance.updatedAt,
      'columns': instance.columns,
    };
