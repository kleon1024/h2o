// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'row.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RowBean _$RowBeanFromJson(Map<String, dynamic> json) {
  return RowBean(
    uuid: json['uuid'] as String,
    values: (json['values'] as List<dynamic>).map((e) => e as Object).toList(),
  );
}

Map<String, dynamic> _$RowBeanToJson(RowBean instance) => <String, dynamic>{
      'uuid': instance.uuid,
      'values': instance.values,
    };
