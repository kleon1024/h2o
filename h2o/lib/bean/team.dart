import 'package:json_annotation/json_annotation.dart';

part 'team.g.dart';

@JsonSerializable()
class TeamBean {
  String id;
  String name;

  TeamBean({
    required this.id,
    required this.name,
  });

  factory TeamBean.fromJson(Map<String, dynamic> json) =>
      _$TeamBeanFromJson(json);

  Map<String, dynamic> toJson() => _$TeamBeanToJson(this);
}
