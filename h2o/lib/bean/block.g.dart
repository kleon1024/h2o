// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'block.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BlockBean _$BlockBeanFromJson(Map<String, dynamic> json) {
  return BlockBean(
    id: json['id'] as int,
    uuid: json['uuid'] as String,
    previousId: json['previous_id'] as String,
    type: json['type'] as String,
    text: json['text'] as String,
    revision: json['revision'] as int,
    authorId: json['author_id'] as String,
    createdAt: json['created_at'] as int,
    updatedAt: json['updated_at'] as int,
  );
}

Map<String, dynamic> _$BlockBeanToJson(BlockBean instance) => <String, dynamic>{
      'id': instance.id,
      'uuid': instance.uuid,
      'type': instance.type,
      'text': instance.text,
      'revision': instance.revision,
      'author_id': instance.authorId,
      'previous_id': instance.previousId,
      'created_at': instance.createdAt,
      'updated_at': instance.updatedAt,
    };
