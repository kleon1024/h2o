import 'package:enum_to_string/enum_to_string.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:h2o/bean/column.dart';
import 'package:h2o/bean/node.dart';
import 'package:h2o/bean/row.dart';
import 'package:h2o/dao/table.dart';
import 'package:h2o/dao/transaction.dart';
import 'package:h2o/model/global.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:uuid/uuid.dart';

class DataTableCell {
  String name;
  Object value;
  DataTableCell({required this.name, required this.value});
}

class TablePageModel extends DataGridSource {
  BuildContext context;
  GlobalModel globalModel;

  NodeBean node;

  TablePageModel(this.context, this.node)
      : globalModel = Provider.of<GlobalModel>(context) {
    debugPrint("New Table Page Model");
    this.globalModel.tableDao!.loadTables(node);
    // this.globalModel.registerCallback(EventType.COLUMN_CREATED, refresh);
    // this.globalModel.registerCallback(EventType.TABLE_UPDATED, updateFocus);
    // this.globalModel.registerCallback(EventType.COLUMN_CREATED, updateFocus);
  }

  List<RowBean> get rawRows => () {
        var rows = this.globalModel.tableDao!.tableRowMap[node.uuid];
        if (rows == null) {
          rows = [];
        }
        return rows;
      }();

  List<ColumnBean> get rawColumns => () {
        var cols = this.globalModel.tableDao!.tableColumnMap[node.uuid];
        if (cols == null) {
          cols = [];
        }
        return cols;
      }();

  @override
  List<DataGridRow> get rows => this
      .rawRows
      .map<DataGridRow>((r) => DataGridRow(cells: () {
            List<DataGridCell> cells = [];
            for (int i = 0; i < rawColumns.length; i++) {
              cells.add(DataGridCell<Object>(
                  columnName: rawColumns[i].name, value: r.values[i]));
            }
            return cells;
          }()))
      .toList();

  @override
  DataGridRowAdapter? buildRow(DataGridRow row) {
    return DataGridRowAdapter(
        cells: row.getCells().map<Widget>((dataGridCell) {
      return Container(
          alignment: Alignment.centerLeft,
          padding: EdgeInsets.symmetric(horizontal: 8),
          child: Text(
            dataGridCell.value.toString(),
            style: Theme.of(context).textTheme.bodyText2!,
            overflow: TextOverflow.ellipsis,
          ));
    }).toList());
  }

  @override
  void onCellSubmit(DataGridRow dataGridRow, RowColumnIndex rowColumnIndex,
      GridColumn column) {}

  handleRawKeyEvent(RawKeyEvent event) {
    if (event is RawKeyDownEvent &&
        event.logicalKey == LogicalKeyboardKey.enter) {
      notifyListeners();
    }
  }

  @override
  Widget? buildEditWidget(DataGridRow dataGridRow,
      RowColumnIndex rowColumnIndex, GridColumn column, CellSubmit submitCell) {
    // Text going to display on editable widget
    ColumnBean column = rawColumns[rowColumnIndex.columnIndex];
    RowBean row = rawRows[rowColumnIndex.rowIndex];
    final Object obj = row.values[rowColumnIndex.columnIndex];
    String displayText = obj.toString();

    Object newCellValue = '';
    TextEditingController editingController = TextEditingController();

    List<TextInputFormatter> formatters = [];
    if (column.type == EnumToString.convertToString(ColumnType.integer)) {
      formatters.add(FilteringTextInputFormatter.allow(RegExp(r"[0-9]")));
    }
    var focusNode = FocusNode();
    focusNode.addListener(() {
      if (!focusNode.hasFocus) {
        debugPrint("lost focus");
        this.globalModel.transactionDao!.transaction(Transaction([
              Operation(OperationType.UpdateRow, node: node, columns: [
                column.uuid
              ], rows: [
                RowBean(uuid: row.uuid, values: [editingController.text])
              ])
            ]));
        notifyListeners();
      }
    });
    var tf = TextField(
      autofocus: true,
      focusNode: focusNode,
      controller: editingController..text = displayText,
      textAlign: TextAlign.left,
      style: Theme.of(context).textTheme.bodyText1!,
      inputFormatters: formatters,
      decoration: InputDecoration(
        isDense: true,
        border: InputBorder.none,
        focusedBorder: InputBorder.none,
        enabledBorder: InputBorder.none,
        errorBorder: InputBorder.none,
        disabledBorder: InputBorder.none,
        contentPadding: const EdgeInsets.fromLTRB(0, 0, 0, 1.0),
      ),
      keyboardType: TextInputType.text,
      onChanged: (String value) {
        if (column.type == EnumToString.convertToString(ColumnType.string)) {
          newCellValue = value;
        } else if (column.type ==
            EnumToString.convertToString(ColumnType.integer)) {
          if (value.length == 0) {
            value = '0';
          } else {
            newCellValue = int.parse(value);
          }
        }

        row.values[rowColumnIndex.columnIndex] = newCellValue;
      },
    );

    return Container(
      padding: const EdgeInsets.all(8.0),
      alignment: Alignment.centerLeft,
      child: RawKeyboardListener(
        focusNode: FocusNode(),
        onKey: handleRawKeyEvent,
        child: tf,
      ),
    );
  }

  bool sorting = false;
  String sortColumn = "";
  DataGridSortDirection sortDirection = DataGridSortDirection.ascending;

  onTapCreateRow() async {
    List<Object> row = [];
    List<String> columnsStr = [];
    List<String> rowStr = [];
    this.globalModel.tableDao!.tableColumnMap[node.uuid]!.forEach((c) {
      if (EnumToString.convertToString(ColumnType.integer) == c.type) {
        row.add(int.parse(c.defaultValue));
      } else {
        row.add(c.defaultValue);
      }
      columnsStr.add(c.uuid);
      rowStr.add(c.defaultValue);
    });
    var rowBean = RowBean(uuid: Uuid().v4(), values: row);

    List<RowBean> rows = this.globalModel.tableDao!.tableRowMap[node.uuid]!;
    rows.add(rowBean);

    this.globalModel.transactionDao!.transaction(Transaction([
          Operation(OperationType.InsertRow,
              node: node, columns: columnsStr, rows: [rowBean])
        ]));

    notifyListeners();
  }

  onTapEmptyArea() {
    notifyListeners();
  }

  Future refresh() async {
    notifyListeners();
  }
}
