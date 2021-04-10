import 'package:json_annotation/json_annotation.dart';

part 'block.g.dart';

@JsonSerializable()
class BlockBean {
  String id;
  String type;
  String text;
  int revision;
  String authorID;
  String updatedAt;

  BlockBean({
    required this.id,
    required this.type,
    required this.text,
    required this.revision,
    required this.authorID,
    required this.updatedAt,
  });

  factory BlockBean.fromJson(Map<String, dynamic> json) =>
      _$BlockBeanFromJson(json);

  Map<String, dynamic> toJson() => _$BlockBeanToJson(this);
}
