import 'package:h2o/global/consts.dart';
import 'package:json_annotation/json_annotation.dart';

part 'block.g.dart';

@JsonSerializable()
class BlockBean {
  String id;
  String preBlockID;
  String posBlockID;
  String type;
  String text;
  int revision;
  String authorID;
  String updatedAt;

  BlockBean({
    this.id = EMPTY_UUID,
    this.preBlockID = EMPTY_UUID,
    this.posBlockID = EMPTY_UUID,
    this.type = "text",
    this.text = "",
    this.revision = 0,
    this.authorID = EMPTY_UUID,
    this.updatedAt = "",
  });

  factory BlockBean.fromJson(Map<String, dynamic> json) =>
      _$BlockBeanFromJson(json);

  Map<String, dynamic> toJson() => _$BlockBeanToJson(this);
}
