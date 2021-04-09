// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'node.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NodeBean _$NodeBeanFromJson(Map<String, dynamic> json) {
  return NodeBean(
    id: json['id'] as String,
    type: json['type'] as String,
    name: json['name'] as String,
    parentID: json['parentID'] as String,
  );
}

Map<String, dynamic> _$NodeBeanToJson(NodeBean instance) => <String, dynamic>{
      'id': instance.id,
      'type': instance.type,
      'name': instance.name,
      'parentID': instance.parentID,
    };
