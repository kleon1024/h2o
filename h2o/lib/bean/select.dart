import 'package:h2o/global/constants.dart';
import 'package:json_annotation/json_annotation.dart';

part 'select.g.dart';

@JsonSerializable()
class SelectBean {
  String uuid;
  String text;
  @JsonKey(name: "column_id")
  String columnId;
  int color;

  SelectBean({
    this.uuid = EMPTY_UUID,
    this.text = "",
    this.columnId = "",
    this.color = 0,
  });

  factory SelectBean.fromJson(Map<String, dynamic> json) =>
      _$SelectBeanFromJson(json);

  Map<String, dynamic> toJson() => _$SelectBeanToJson(this);
}
