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
  date,
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

    tableRowMap[nodeBean.uuid] = await DBProvider.db.getRows(nodeBean.uuid,
        tableColumnMap[nodeBean.uuid]!.map((c) => c.uuid).toList());
    notifyListeners();
  }

  // Future updateTables(NodeBean nodeBean) async {
  //   TableBean? table = await Api.getNodeTable(
  //     nodeBean.uuid,
  //     options: this.globalModel!.userDao!.accessTokenOptions(),
  //     cancelToken: cancelToken,
  //   );
  //
  //   if (table != null) {
  //     tableMap[nodeBean.uuid] = table;
  //
  //     if (table.columns.length == 0) {
  //       if (tableRowMap[nodeBean.uuid] == null) {
  //         tableRowMap[nodeBean.uuid] = [];
  //       }
  //       this.globalModel!.triggerCallback(EventType.TABLE_UPDATED);
  //       return;
  //     }
  //     notifyListeners();
  //
  //     List<Map<String, String>>? rows = await Api.getTableRows(
  //       table.uuid,
  //       data: {
  //         'columns': table.columns.map((c) => c.id).toList(),
  //         'offset': 0,
  //         'limit': 10
  //       },
  //       options: this.globalModel!.userDao!.accessTokenOptions(),
  //       cancelToken: cancelToken,
  //     );
  //     if (rows != null) {
  //       tableRowMap[nodeBean.uuid] = rows;
  //       this.globalModel!.triggerCallback(EventType.TABLE_UPDATED);
  //     }
  //     notifyListeners();
  //   }
  // }

  @override
  void dispose() {
    super.dispose();
    if (!cancelToken.isCancelled) cancelToken.cancel();
  }
}
