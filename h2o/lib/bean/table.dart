import 'package:h2o/bean/column.dart';
import 'package:h2o/global/constants.dart';
import 'package:json_annotation/json_annotation.dart';

part 'table.g.dart';

@JsonSerializable()
class TableBean {
  String uuid;
  @JsonKey(name: "node_id")
  String nodeId;
  @JsonKey(name: "created_at")
  int createdAt;
  @JsonKey(name: "updated_at")
  int updatedAt;
  List<ColumnBean> columns;

  TableBean({
    this.uuid = EMPTY_UUID,
    this.nodeId = EMPTY_UUID,
    this.createdAt = 0,
    this.updatedAt = 0,
    required this.columns,
  });

  factory TableBean.fromJson(Map<String, dynamic> json) =>
      _$TableBeanFromJson(json);

  Map<String, dynamic> toJson() => _$TableBeanToJson(this);
}
