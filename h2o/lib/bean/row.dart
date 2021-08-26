import 'package:h2o/global/constants.dart';
import 'package:json_annotation/json_annotation.dart';

part 'row.g.dart';

@JsonSerializable()
class RowBean {
  String uuid;
  @JsonKey(name: "created_at")
  int createdAt;
  @JsonKey(name: "updated_at")
  int updatedAt;
  @JsonKey(name: "created_by")
  String createdBy;
  @JsonKey(name: "updated_by")
  String updatedBy;
  List<Object> values;

  RowBean({
    this.uuid = EMPTY_UUID,
    required this.values,
    this.createdAt = 0,
    this.updatedAt = 0,
    this.createdBy = "",
    this.updatedBy = "",
  });

  factory RowBean.fromJson(Map<String, dynamic> json) =>
      _$RowBeanFromJson(json);

  Map<String, dynamic> toJson() => _$RowBeanToJson(this);
}
