// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'node.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NodeBean _$NodeBeanFromJson(Map<String, dynamic> json) {
  return NodeBean(
    uuid: json['uuid'] as String,
    type: json['type'] as String,
    name: json['name'] as String,
    indent: json['indent'] as int,
    previousId: json['previous_id'] as String,
    parentId: json['parent_id'] as String,
    teamId: json['team_id'] as String,
    createdAt: json['created_at'] as int,
    updatedAt: json['updated_at'] as int,
  );
}

Map<String, dynamic> _$NodeBeanToJson(NodeBean instance) => <String, dynamic>{
      'uuid': instance.uuid,
      'type': instance.type,
      'name': instance.name,
      'indent': instance.indent,
      'parent_id': instance.parentId,
      'previous_id': instance.previousId,
      'created_at': instance.createdAt,
      'updated_at': instance.updatedAt,
      'team_id': instance.teamId,
    };
