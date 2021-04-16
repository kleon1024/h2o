import 'package:flutter/cupertino.dart';
import 'package:h2o/api/api.dart';
import 'package:h2o/bean/column.dart';
import 'package:h2o/bean/node.dart';
import 'package:h2o/bean/table.dart';
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
    this.globalModel.registerCallback(EventType.TABLE_UPDATED, updateFocus);
    this.globalModel.registerCallback(EventType.COLUMN_CREATED, updateFocus);
  }

  final editingController = TextEditingController();
  final Map<int, Map<String, FocusNode>> focusMap = {};
  int editingRowIndex = -1;
  ColumnBean editingColumn = ColumnBean();

  Future refresh() async {
    notifyListeners();
  }

  Future updateFocus() async {
    List<ColumnBean> columns =
        this.globalModel.tableDao!.tableMap[node.id]!.columns;
    List<Map<String, String>> rows =
        this.globalModel.tableDao!.tableRowMap[node.id]!;
    debugPrint("updated focus map :" +
        rows.length.toString() +
        " x " +
        columns.length.toString());
    for (int i = 0; i < rows.length; i++) {
      focusMap[i] = {};
      for (int j = 0; j < columns.length; j++) {
        focusMap[i]![columns[j].id] = FocusNode();
      }
    }
  }

  onTapCreateRow() async {
    TableBean table = this.globalModel.tableDao!.tableMap[node.id]!;
    Map<String, String> row = {};
    this.globalModel.tableDao!.tableMap[node.id]!.columns.forEach((c) {
      row[c.id] = c.defaultValue;
    });

    List<Map<String, String>> rows =
        this.globalModel.tableDao!.tableRowMap[node.id]!;
    rows.add(row);
    debugPrint("add " + row.toString());

    notifyListeners();

    Map<String, String>? retRow = await Api.createRow(
      table.id,
      data: {'row': row},
      options: this.globalModel.userDao!.accessTokenOptions(),
    );
    if (retRow != null) {}
  }

  onTapCell(int rowIndex, ColumnBean columnBean, String value) async {
    debugPrint(
        "on tap cell:" + rowIndex.toString() + "," + columnBean.id.toString());
    editingRowIndex = rowIndex;
    editingColumn = columnBean;
    editingController.text = value;
    focusMap[editingRowIndex]![editingColumn.id]!.requestFocus();
    notifyListeners();
  }

  onTapEmptyArea() async {
    editingRowIndex = -1;
    editingColumn = ColumnBean();
    editingController.text = "";
    notifyListeners();
  }
}
