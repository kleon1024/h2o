// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'table.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TableBean _$TableBeanFromJson(Map<String, dynamic> json) {
  return TableBean(
    id: json['id'] as String,
    columns: (json['columns'] as List<dynamic>)
        .map((e) => ColumnBean.fromJson(e as Map<String, dynamic>))
        .toList(),
  );
}

Map<String, dynamic> _$TableBeanToJson(TableBean instance) => <String, dynamic>{
      'id': instance.id,
      'columns': instance.columns,
    };
