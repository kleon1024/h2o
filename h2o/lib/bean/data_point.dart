import 'package:json_annotation/json_annotation.dart';

part 'data_point.g.dart';

@JsonSerializable()
class DataPoint {
  Object x;
  num y;

  DataPoint({
    required this.x,
    required this.y,
  });

  factory DataPoint.fromJson(Map<String, dynamic> json) =>
      _$DataPointFromJson(json);

  Map<String, dynamic> toJson() => _$DataPointToJson(this);
}
