import 'package:h2o/global/constants.dart';
import 'package:json_annotation/json_annotation.dart';

part 'block.g.dart';

@JsonSerializable()
class BlockBean {
  String uuid;
  String type;
  String text;
  int revision;
  @JsonKey(name: "author_id")
  String authorId;
  @JsonKey(name: "previous_id")
  String previousId;
  @JsonKey(name: "created_at")
  int createdAt;
  @JsonKey(name: "updated_at")
  int updatedAt;

  BlockBean({
    this.uuid = EMPTY_UUID,
    this.previousId = EMPTY_UUID,
    this.type = "text",
    this.text = "",
    this.revision = 0,
    this.authorId = EMPTY_UUID,
    this.createdAt = 0,
    this.updatedAt = 0,
  });

  factory BlockBean.copyFrom(BlockBean bean) {
    return BlockBean(
      uuid: bean.uuid,
      previousId: bean.previousId,
      type: bean.type,
      text: bean.text,
      revision: bean.revision,
      authorId: bean.authorId,
      updatedAt: bean.updatedAt,
    );
  }

  factory BlockBean.fromJson(Map<String, dynamic> json) =>
      _$BlockBeanFromJson(json);

  Map<String, dynamic> toJson() => _$BlockBeanToJson(this);
}
