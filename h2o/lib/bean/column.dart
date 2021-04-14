import 'package:h2o/global/constants.dart';
import 'package:json_annotation/json_annotation.dart';

part 'column.g.dart';

@JsonSerializable()
class ColumnBean {
  String id;
  String name;
  String type;

  ColumnBean({
    this.id = EMPTY_UUID,
    this.name = "column",
    this.type = "string",
  });

  factory ColumnBean.fromJson(Map<String, dynamic> json) =>
      _$ColumnBeanFromJson(json);

  Map<String, dynamic> toJson() => _$ColumnBeanToJson(this);
}
