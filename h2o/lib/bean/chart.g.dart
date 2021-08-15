// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chart.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ChartBean _$ChartBeanFromJson(Map<String, dynamic> json) {
  return ChartBean(
    table: json['table'] as String,
    series: (json['series'] as List<dynamic>)
        .map((e) => ChartSeries.fromJson(e as Map<String, dynamic>))
        .toList(),
  );
}

Map<String, dynamic> _$ChartBeanToJson(ChartBean instance) => <String, dynamic>{
      'table': instance.table,
      'series': instance.series,
    };
