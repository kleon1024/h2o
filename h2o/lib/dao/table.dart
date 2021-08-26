import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:h2o/bean/column.dart';
import 'package:h2o/bean/node.dart';
import 'package:h2o/bean/row.dart';
import 'package:h2o/db/db.dart';
import 'package:h2o/model/global.dart';

enum ColumnType {
  string,
  integer,
  number,
  date,
  select,
  multi_select,
  created_time,
  updated_time,
}

class TableDao extends ChangeNotifier {
  BuildContext? context;
  // Map<String, TableBean> tableMap = {};
  Map<String, List<ColumnBean>> tableColumnMap = {};
  Map<String, List<RowBean>> tableRowMap = {};
  CancelToken cancelToken = CancelToken();
  GlobalModel? globalModel;

  setContext(BuildContext context, GlobalModel globalModel) async {
    if (this.context == null) {
      this.context = context;
      this.globalModel = globalModel;
      globalModel.tableDao = this;
    }
  }

  Future loadTables(NodeBean nodeBean) async {
    tableColumnMap[nodeBean.uuid] =
        await DBProvider.db.getColumns(nodeBean.uuid);

    List<ColumnBean> columns = tableColumnMap[nodeBean.uuid]!;
    List<String> cols = [];
    for (var c in columns) {
      cols.add(c.uuid);
    }

    tableRowMap[nodeBean.uuid] =
        await DBProvider.db.getRows(nodeBean.uuid, cols);
    notifyListeners();
  }

  @override
  void dispose() {
    super.dispose();
    if (!cancelToken.isCancelled) cancelToken.cancel();
  }
}
