// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'node.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NodeBean _$NodeBeanFromJson(Map<String, dynamic> json) {
  return NodeBean(
    id: json['id'] as int,
    uuid: json['uuid'] as String,
    type: json['type'] as String,
    name: json['name'] as String,
    indent: json['indent'] as int,
    previousId: json['previous_id'] as String,
    createdAt: json['created_at'] as int,
    updatedAt: json['updated_at'] as int,
  );
}

Map<String, dynamic> _$NodeBeanToJson(NodeBean instance) => <String, dynamic>{
      'id': instance.id,
      'uuid': instance.uuid,
      'type': instance.type,
      'name': instance.name,
      'indent': instance.indent,
      'previous_id': instance.previousId,
      'created_at': instance.createdAt,
      'updated_at': instance.updatedAt,
    };
