import 'package:json_annotation/json_annotation.dart';

part 'team.g.dart';

@JsonSerializable()
class TeamBean {
  String uuid;
  String name;

  TeamBean({
    required this.uuid,
    required this.name,
  });

  factory TeamBean.fromJson(Map<String, dynamic> json) =>
      _$TeamBeanFromJson(json);

  Map<String, dynamic> toJson() => _$TeamBeanToJson(this);
}
