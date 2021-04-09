import 'package:json_annotation/json_annotation.dart';

part 'node.g.dart';

@JsonSerializable()
class NodeBean {
  String id;
  String type;
  String name;
  String parentID;

  NodeBean({
    required this.id,
    required this.type,
    required this.name,
    required this.parentID,
  });

  factory NodeBean.fromJson(Map<String, dynamic> json) =>
      _$NodeBeanFromJson(json);

  Map<String, dynamic> toJson() => _$NodeBeanToJson(this);
}
