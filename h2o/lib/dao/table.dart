import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:h2o/api/api.dart';
import 'package:h2o/bean/node.dart';
import 'package:h2o/bean/table.dart';
import 'package:h2o/model/global.dart';

enum ColumnType {
  string,
  integer,
  date,
}

class TableDao extends ChangeNotifier {
  BuildContext? context;
  Map<String, TableBean> tableMap = {};
  Map<String, List<Map<String, String>>> tableRowMap = {};
  CancelToken cancelToken = CancelToken();
  GlobalModel? globalModel;

  setContext(BuildContext context, GlobalModel globalModel) async {
    if (this.context == null) {
      this.context = context;
      this.globalModel = globalModel;
      globalModel.tableDao = this;
    }
  }

  Future updateTables(NodeBean nodeBean) async {
    TableBean? table = await Api.getNodeTable(
      nodeBean.id,
      options: this.globalModel!.userDao!.accessTokenOptions(),
      cancelToken: cancelToken,
    );

    if (table != null) {
      tableMap[nodeBean.id] = table;
      notifyListeners();
      if (table.columns.length == 0) return;

      List<Map<String, String>>? rows = await Api.getTableRows(
        table.id,
        data: {
          'columns': table.columns.map((c) => c.id).toList(),
          'offset': 0,
          'limit': 10
        },
        options: this.globalModel!.userDao!.accessTokenOptions(),
        cancelToken: cancelToken,
      );
      if (rows != null) {
        tableRowMap[nodeBean.id] = rows;
      }
      notifyListeners();
    }
  }

  @override
  void dispose() {
    super.dispose();
    if (!cancelToken.isCancelled) cancelToken.cancel();
  }
}
