import 'package:json_annotation/json_annotation.dart';

part 'token.g.dart';

@JsonSerializable()
class TokenBean {
  String token;
  String expiresAt;

  TokenBean({
    required this.token,
    required this.expiresAt,
  });

  factory TokenBean.fromJson(Map<String, dynamic> json) =>
      _$TokenBeanFromJson(json);

  Map<String, dynamic> toJson() => _$TokenBeanToJson(this);
}
