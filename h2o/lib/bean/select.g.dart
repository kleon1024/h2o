// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'select.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SelectBean _$SelectBeanFromJson(Map<String, dynamic> json) {
  return SelectBean(
    uuid: json['uuid'] as String,
    text: json['text'] as String,
    columnId: json['column_id'] as String,
    color: json['color'] as int,
  );
}

Map<String, dynamic> _$SelectBeanToJson(SelectBean instance) =>
    <String, dynamic>{
      'uuid': instance.uuid,
      'text': instance.text,
      'column_id': instance.columnId,
      'color': instance.color,
    };
