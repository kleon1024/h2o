import 'package:h2o/bean/select.dart';
import 'package:h2o/global/constants.dart';
import 'package:json_annotation/json_annotation.dart';

part 'column.g.dart';

@JsonSerializable()
class ColumnBean {
  String uuid;
  String name;
  String type;
  @JsonKey(name: "default_value")
  String defaultValue;
  @JsonKey(name: "table_id")
  String tableId;
  @JsonKey(name: "created_at")
  int createdAt;
  @JsonKey(name: "updated_at")
  int updatedAt;
  @JsonKey(ignore: true)
  List<SelectBean>? selects;

  ColumnBean({
    this.uuid = EMPTY_UUID,
    this.name = "column",
    this.type = "string",
    this.defaultValue = "",
    this.tableId = EMPTY_UUID,
    this.createdAt = 0,
    this.updatedAt = 0,
    this.selects,
  });

  factory ColumnBean.fromJson(Map<String, dynamic> json) =>
      _$ColumnBeanFromJson(json);

  Map<String, dynamic> toJson() => _$ColumnBeanToJson(this);
}
