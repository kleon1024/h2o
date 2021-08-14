import 'package:json_annotation/json_annotation.dart';

part 'node.g.dart';

@JsonSerializable()
class NodeBean {
  String uuid;
  String type;
  String name;
  int indent;
  @JsonKey(name: "previous_id")
  String previousId;
  @JsonKey(name: "created_at")
  int createdAt;
  @JsonKey(name: "updated_at")
  int updatedAt;
  @JsonKey(name: "team_id")
  String teamId;
  @JsonKey(ignore: true)
  bool expanded;

  NodeBean({
    required this.uuid,
    required this.type,
    required this.name,
    required this.indent,
    required this.previousId,
    required this.teamId,
    this.createdAt = 0,
    this.updatedAt = 0,
    this.expanded = false,
  });

  factory NodeBean.fromJson(Map<String, dynamic> json) =>
      _$NodeBeanFromJson(json);

  Map<String, dynamic> toJson() => _$NodeBeanToJson(this);
}
