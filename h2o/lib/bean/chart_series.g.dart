// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chart_series.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ChartSeries _$ChartSeriesFromJson(Map<String, dynamic> json) {
  return ChartSeries(
    type: json['type'] as String,
    name: json['name'] as String,
    x: json['x'] as String,
    y: json['y'] as String,
    x_title: json['x_title'] as String,
    y_title: json['y_title'] as String,
    where: json['where'] as String,
    order: json['order'] as String,
    offset: json['offset'] as int,
    limit: json['limit'] as int,
    points: (json['points'] as List<dynamic>)
        .map((e) => DataPoint.fromJson(e as Map<String, dynamic>))
        .toList(),
  );
}

Map<String, dynamic> _$ChartSeriesToJson(ChartSeries instance) =>
    <String, dynamic>{
      'type': instance.type,
      'name': instance.name,
      'x': instance.x,
      'y': instance.y,
      'x_title': instance.x_title,
      'y_title': instance.y_title,
      'where': instance.where,
      'order': instance.order,
      'offset': instance.offset,
      'limit': instance.limit,
      'points': instance.points,
    };
