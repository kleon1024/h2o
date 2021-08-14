import 'package:h2o/global/constants.dart';
import 'package:json_annotation/json_annotation.dart';

part 'row.g.dart';

@JsonSerializable()
class RowBean {
  String uuid;
  List<Object> values;

  RowBean({
    this.uuid = EMPTY_UUID,
    required this.values,
  });

  factory RowBean.fromJson(Map<String, dynamic> json) =>
      _$RowBeanFromJson(json);

  Map<String, dynamic> toJson() => _$RowBeanToJson(this);
}
