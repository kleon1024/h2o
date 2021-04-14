import 'package:h2o/bean/column.dart';
import 'package:h2o/global/constants.dart';
import 'package:json_annotation/json_annotation.dart';

part 'table.g.dart';

@JsonSerializable()
class TableBean {
  String id;
  List<ColumnBean> columns;

  TableBean({
    this.id = EMPTY_UUID,
    this.columns = const [],
  });

  factory TableBean.fromJson(Map<String, dynamic> json) =>
      _$TableBeanFromJson(json);

  Map<String, dynamic> toJson() => _$TableBeanToJson(this);
}
