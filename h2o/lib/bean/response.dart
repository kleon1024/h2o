import 'package:json_annotation/json_annotation.dart';

part 'response.g.dart';

@JsonSerializable()
class ResponseBean {
  int errorCode;
  String errorMessage;
  dynamic data;

  ResponseBean({
    required this.errorCode,
    required this.errorMessage,
    required this.data,
  });

  factory ResponseBean.fromJson(Map<String, dynamic> json) =>
      _$ResponseBeanFromJson(json);

  Map<String, dynamic> toJson() => _$ResponseBeanToJson(this);
}
