// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'block.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BlockBean _$BlockBeanFromJson(Map<String, dynamic> json) {
  return BlockBean(
    id: json['id'] as String,
    preBlockID: json['preBlockID'] as String,
    posBlockID: json['posBlockID'] as String,
    type: json['type'] as String,
    text: json['text'] as String,
    revision: json['revision'] as int,
    authorID: json['authorID'] as String,
    updatedAt: json['updatedAt'] as String,
  );
}

Map<String, dynamic> _$BlockBeanToJson(BlockBean instance) => <String, dynamic>{
      'id': instance.id,
      'preBlockID': instance.preBlockID,
      'posBlockID': instance.posBlockID,
      'type': instance.type,
      'text': instance.text,
      'revision': instance.revision,
      'authorID': instance.authorID,
      'updatedAt': instance.updatedAt,
    };
