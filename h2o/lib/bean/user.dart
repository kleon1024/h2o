import 'package:h2o/bean/team.dart';
import 'package:h2o/bean/token.dart';
import 'package:json_annotation/json_annotation.dart';

part 'user.g.dart';

@JsonSerializable()
class UserBean {
  String id;
  String name;
  TokenBean accessToken;
  TokenBean refreshToken;

  UserBean({
    required this.id,
    required this.name,
    required this.accessToken,
    required this.refreshToken,
  });

  factory UserBean.fromJson(Map<String, dynamic> json) =>
      _$UserBeanFromJson(json);

  Map<String, dynamic> toJson() => _$UserBeanToJson(this);
}
