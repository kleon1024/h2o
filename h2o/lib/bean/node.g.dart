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
    indent: json['indent'] as int,
    preNodeID: json['preNodeID'] as String,
    posNodeID: json['posNodeID'] as String,
  );
}

Map<String, dynamic> _$NodeBeanToJson(NodeBean instance) => <String, dynamic>{
      'id': instance.id,
      'type': instance.type,
      'name': instance.name,
      'indent': instance.indent,
      'preNodeID': instance.preNodeID,
      'posNodeID': instance.posNodeID,
    };
