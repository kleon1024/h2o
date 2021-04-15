import 'package:enum_to_string/enum_to_string.dart';
import 'package:flutter/cupertino.dart';
import 'package:h2o/api/api.dart';
import 'package:h2o/bean/node.dart';
import 'package:h2o/bean/table.dart';
import 'package:h2o/dao/table.dart';
import 'package:h2o/model/global.dart';
import 'package:provider/provider.dart';

class TablePageModel extends ChangeNotifier {
  BuildContext context;
  GlobalModel globalModel;

  NodeBean node;

  TablePageModel(this.context, this.node)
      : globalModel = Provider.of<GlobalModel>(context) {
    this.globalModel.tableDao!.updateTables(node);
  }

  final controller = TextEditingController();
  final Map<String, Map<String, FocusNode>> focusMap = {};

  onTapCreateRow() async {
    TableBean table = this.globalModel.tableDao!.tableMap[node.id]!;
    Map<String, String> rows = {};
    List<String> row = [];
    this.globalModel.tableDao!.tableMap[node.id]!.columns.forEach((c) {
      switch (EnumToString.fromString(ColumnType.values, c.type)!) {
        case ColumnType.string:
          rows[c.id] = "";
          break;
        case ColumnType.integer:
          rows[c.id] = 0.toString();
          break;
        case ColumnType.date:
          rows[c.id] = DateTime.now().toString();
          break;
      }
      row.add(rows[c.id]!);
    });

    this.globalModel.tableDao!.tableRowMap[node.id]!.add(row);
    notifyListeners();

    Map<String, String>? retRow = await Api.createRow(
      table.id,
      data: rows,
      options: this.globalModel.userDao!.accessTokenOptions(),
    );
    if (retRow != null) {}
  }
}
