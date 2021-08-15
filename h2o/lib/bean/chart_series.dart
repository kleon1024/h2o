import 'package:h2o/bean/data_point.dart';
import 'package:json_annotation/json_annotation.dart';

part 'chart_series.g.dart';

@JsonSerializable()
class ChartSeries {
  String type;
  String name;
  String x;
  String y;
  String x_title;
  String y_title;
  String where;
  String order;
  int offset;
  int limit;
  List<DataPoint> points;

  ChartSeries({
    required this.type,
    this.name = "",
    required this.x,
    required this.y,
    this.x_title = "",
    this.y_title = "",
    this.where = "",
    this.order = "",
    this.offset = 0,
    this.limit = 0,
    required this.points,
  });

  factory ChartSeries.fromJson(Map<String, dynamic> json) =>
      _$ChartSeriesFromJson(json);

  Map<String, dynamic> toJson() => _$ChartSeriesToJson(this);
}
