import 'package:json_annotation/json_annotation.dart';

part 'node.g.dart';

@JsonSerializable()
class NodeBean {
  String id;
  String type;
  String name;
  int indent;
  String preNodeID;
  String posNodeID;
  @JsonKey(ignore: true)
  bool expanded;

  NodeBean({
    required this.id,
    required this.type,
    required this.name,
    required this.indent,
    required this.preNodeID,
    required this.posNodeID,
    this.expanded = false,
  });

  factory NodeBean.fromJson(Map<String, dynamic> json) =>
      _$NodeBeanFromJson(json);

  Map<String, dynamic> toJson() => _$NodeBeanToJson(this);
}
