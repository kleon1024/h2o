import 'package:h2o/bean/chart_series.dart';
import 'package:json_annotation/json_annotation.dart';

part 'chart.g.dart';

@JsonSerializable()
class ChartBean {
  String table;
  List<ChartSeries> series;

  ChartBean({
    required this.table,
    required this.series,
  });

  factory ChartBean.fromJson(Map<String, dynamic> json) =>
      _$ChartBeanFromJson(json);

  Map<String, dynamic> toJson() => _$ChartBeanToJson(this);
}
