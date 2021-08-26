import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:h2o/bean/column.dart';
import 'package:h2o/bean/node.dart';
import 'package:h2o/bean/row.dart';
import 'package:h2o/dao/table.dart';
import 'package:h2o/model/global.dart';
import 'package:h2o/model/table/add_column_page.dart';
import 'package:h2o/model/table/table_page.dart';
import 'package:h2o/pages/table/add_column_page.dart';
import 'package:h2o/pages/unified_page.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

class TablePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final tablePageModel = Provider.of<TablePageModel>(context);
    final tableDao = Provider.of<TableDao>(context);
    final globalModel = Provider.of<GlobalModel>(context);

    List<RowBean> rows = [];
    List headers = [];
    List<ColumnBean> columns = [];
    NodeBean node = tablePageModel.node;
    debugPrint("buildTablePage");
    if (tableDao.tableColumnMap.containsKey(node.uuid)) {
      columns = tableDao.tableColumnMap[node.uuid]!;
      headers.addAll(columns.map((c) => c.name));
    }
    if (tableDao.tableRowMap.containsKey(node.uuid)) {
      rows = tableDao.tableRowMap[node.uuid]!;
    }
    List indexColumns =
        List<String>.generate(rows.length, (index) => (index + 1).toString());

    debugPrint("rows:" + rows.toString());
    debugPrint("headers:" + headers.toString());
    debugPrint("indexColumns:" + indexColumns.toString());

    List<List<DataTableCell>> tableRows = [];
    for (int i = 0; i < rows.length; i++) {
      List<DataTableCell> tableRow = [];
      for (int j = 0; j < columns.length; j++) {
        tableRow.add(
            DataTableCell(name: columns[j].name, value: rows[i].values[j]));
      }
      tableRows.add(tableRow);
    }

    List<GridColumn> tableColumns = [];
    columns.forEach((c) {
      tableColumns.add(
        GridColumn(
          columnName: c.name,
          label: GestureDetector(
            onTap: () {
              debugPrint("taped " + c.name.toString());
              tablePageModel.sortedColumns.clear();
              if (c.name == tablePageModel.sortColumn) {
                if (tablePageModel.sorting) {
                  if (tablePageModel.sortDirection ==
                      DataGridSortDirection.descending) {
                    tablePageModel.sortDirection =
                        DataGridSortDirection.ascending;
                  } else if (tablePageModel.sortDirection ==
                      DataGridSortDirection.ascending) {
                    tablePageModel.sorting = false;
                  }
                } else {
                  tablePageModel.sorting = true;
                  tablePageModel.sortDirection =
                      DataGridSortDirection.descending;
                }
              } else {
                tablePageModel.sorting = true;
                tablePageModel.sortColumn = c.name;
                tablePageModel.sortDirection = DataGridSortDirection.descending;
              }
              if (tablePageModel.sorting) {
                tablePageModel.sortedColumns.add(SortColumnDetails(
                    name: tablePageModel.sortColumn,
                    sortDirection: tablePageModel.sortDirection));
              }
              tablePageModel.sort();
            },
            child: Container(
                padding: EdgeInsets.symmetric(horizontal: 8.0),
                alignment: Alignment.centerLeft,
                child: Text(
                  c.name,
                  overflow: TextOverflow.ellipsis,
                )),
          ),
        ),
      );
    });

    var table;
    if (headers.length == 0) {
      table = Container(
          height: MediaQuery.of(context).size.height * 0.65,
          child: Center(
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).push(
                  CupertinoPageRoute(builder: (ctx) {
                    return ChangeNotifierProvider(
                        create: (_) => AddColumnPageModel(
                            context, globalModel, node, tablePageModel),
                        child: AddColumnPage());
                  }),
                );
              },
              icon: Icon(CupertinoIcons.plus),
              label: Text(tr("table.add_column.button")),
            ),
          ));
    } else {
      table = SfDataGrid(
        source: tablePageModel,
        allowEditing: true,
        selectionMode: SelectionMode.single,
        navigationMode: GridNavigationMode.cell,
        columnWidthMode: ColumnWidthMode.lastColumnFill,
        editingGestureType: EditingGestureType.tap,
        footerFrozenRowsCount: 1,
        footer: InkWell(
          onTap: tablePageModel.onTapCreateRow,
          child: Container(
            alignment: Alignment.center,
            child: Icon(CupertinoIcons.plus),
          ),
        ),
        columns: tableColumns,
      );
    }

    return UnifiedPage(
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(36),
          child: AppBar(
            elevation: 0,
            backgroundColor: Colors.transparent,
            title: Text(tablePageModel.node.name),
            actions: [
              IconButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      CupertinoPageRoute(builder: (ctx) {
                        return ChangeNotifierProvider(
                            create: (_) => AddColumnPageModel(
                                context, globalModel, node, tablePageModel),
                            child: AddColumnPage());
                      }),
                    );
                  },
                  icon: Icon(CupertinoIcons.list_bullet_below_rectangle)),
              // IconButton(
              //     onPressed: () {}, icon: Icon(CupertinoIcons.table, size: 16)),
            ],
          ),
        ),
        body: GestureDetector(
          onTap: tablePageModel.onTapEmptyArea,
          child: table,
        ),
      ),
    );
  }
}
