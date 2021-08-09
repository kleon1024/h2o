import 'package:flutter/cupertino.dart';
import 'package:h2o/api/api.dart';
import 'package:h2o/bean/column.dart';
import 'package:h2o/bean/node.dart';
import 'package:h2o/bean/table.dart';
import 'package:h2o/global/constants.dart';
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
        this.globalModel.tableDao!.tableMap[node.uuid]!.columns;
    List<Map<String, String>> rows =
        this.globalModel.tableDao!.tableRowMap[node.uuid]!;
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
    TableBean table = this.globalModel.tableDao!.tableMap[node.uuid]!;
    Map<String, String> row = {};
    this.globalModel.tableDao!.tableMap[node.uuid]!.columns.forEach((c) {
      row[c.id] = c.defaultValue;
    });

    List<Map<String, String>> rows =
        this.globalModel.tableDao!.tableRowMap[node.uuid]!;
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
    if (editingRowIndex >= 0 && editingColumn.id != EMPTY_UUID) {
      TableBean table = this.globalModel.tableDao!.tableMap[node.uuid]!;
      Map<String, String> row =
          this.globalModel.tableDao!.tableRowMap[node.uuid]![editingRowIndex];
      Map<String, String> patchRow = {
        editingColumn.id: editingController.text,
      };
      row[editingColumn.id] = editingController.text;
      // TODO Guarantee Success
      Api.patchRow(
        table.id,
        row["id"]!,
        data: {"row": patchRow},
        options: this.globalModel.userDao!.accessTokenOptions(),
      );
    }

    editingRowIndex = -1;
    editingColumn = ColumnBean();
    editingController.text = "";
    notifyListeners();
  }

  onIntegerValueTextFieldChanged(String text) {
    if (text.isEmpty) {
      text = "0";
    }
    while (text.length > 1 && text.startsWith("0")) {
      text = text.substring(1);
    }
    editingController.text = text;
    editingController.selection = TextSelection.fromPosition(
        TextPosition(offset: editingController.text.length));
    notifyListeners();
  }
}
