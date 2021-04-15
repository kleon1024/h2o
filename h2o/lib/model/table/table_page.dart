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
    this.globalModel.registerCallback(EventType.COLUMN_CREATED, refresh);
  }

  final controller = TextEditingController();
  final Map<String, Map<String, FocusNode>> focusMap = {};

  Future refresh() async {
    notifyListeners();
  }

  onTapCreateRow() async {
    TableBean table = this.globalModel.tableDao!.tableMap[node.id]!;
    Map<String, String> row = {};
    this.globalModel.tableDao!.tableMap[node.id]!.columns.forEach((c) {
      switch (EnumToString.fromString(ColumnType.values, c.type)!) {
        case ColumnType.string:
          row[c.id] = "";
          break;
        case ColumnType.integer:
          row[c.id] = 0.toString();
          break;
        case ColumnType.date:
          row[c.id] = DateTime.now().toString();
          break;
      }
    });

    List<Map<String, String>>? rows =
        this.globalModel.tableDao!.tableRowMap[node.id];
    if (rows == null) {
      rows = [];
    }
    rows.add(row);

    notifyListeners();

    Map<String, String>? retRow = await Api.createRow(
      table.id,
      data: {'row': row},
      options: this.globalModel.userDao!.accessTokenOptions(),
    );
    if (retRow != null) {}
  }
}
