import 'package:easy_localization/easy_localization.dart';
import 'package:enum_to_string/enum_to_string.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:h2o/bean/column.dart';
import 'package:h2o/bean/node.dart';
import 'package:h2o/bean/table.dart';
import 'package:h2o/components/scroll/bouncing_scroll_view.dart';
import 'package:h2o/dao/table.dart';
import 'package:h2o/model/global.dart';
import 'package:h2o/model/table/add_column_page.dart';
import 'package:h2o/model/table/table_page.dart';
import 'package:h2o/pages/table/add_column_page.dart';
import 'package:horizontal_data_table/horizontal_data_table.dart';
import 'package:provider/provider.dart';

class TablePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final tablePageModel = Provider.of<TablePageModel>(context);
    final tableDao = Provider.of<TableDao>(context);
    final globalModel = Provider.of<GlobalModel>(context);

    List<Map<String, String>> rows = [];
    List headers = [];
    List<ColumnBean> columns = [];
    NodeBean node = tablePageModel.node;
    TableBean? tableBean;
    debugPrint("buildTablePage");
    if (tableDao.tableMap.containsKey(node.id)) {
      columns = tableDao.tableMap[node.id]!.columns;
      headers.addAll(columns.map((c) => c.name));
      tableBean = tableDao.tableMap[node.id];
    }
    if (tableDao.tableRowMap.containsKey(node.id)) {
      rows = tableDao.tableRowMap[node.id]!;
    }
    List indexColumns =
        List<String>.generate(rows.length, (index) => (index + 1).toString());
    debugPrint(tableDao.tableRowMap.keys.toString());
    debugPrint("rows:" + rows.toString());
    debugPrint("headers:" + headers.toString());
    debugPrint("indexColumns:" + indexColumns.toString());

    var table;
    if (headers.length == 0) {
      table = Container(
          height: MediaQuery.of(context).size.height * 0.65,
          child: Center(
              child: ElevatedButton.icon(
            onPressed: tableBean == null
                ? null
                : () {
                    Navigator.of(context).push(
                      CupertinoPageRoute(builder: (ctx) {
                        return ChangeNotifierProvider(
                            create: (_) => AddColumnPageModel(
                                context, globalModel, tableBean!, node),
                            child: AddColumnPage());
                      }),
                    );
                  },
            icon: Icon(CupertinoIcons.plus),
            label: Text(tr("table.add_column.button")),
          )));
    } else {
      headers.insert(0, "#");

      var width = 60.0;
      var height = 25.0;

      table = Container(
        // width: 700,
        height: (rows.length + 1) * height + 10,
        child: HorizontalDataTable(
          leftHandSideColBackgroundColor: Colors.transparent,
          rightHandSideColBackgroundColor: Colors.transparent,
          isFixedHeader: true,
          leftHandSideColumnWidth: 30,
          rightHandSideColumnWidth: columns.length * width,
          itemCount: rows.length,
          headerWidgets: headers
              .map((h) => InkWell(
                  hoverColor: Theme.of(context).hoverColor,
                  onTap: () {},
                  child: Container(
                    width: width,
                    height: height,
                    alignment: Alignment.centerLeft,
                    child: Text(h),
                  )))
              .toList(),
          leftSideItemBuilder: (context, index) {
            return InkWell(
              onTap: () {},
              hoverColor: Theme.of(context).hoverColor,
              child: Container(
                height: height,
                width: 20,
                alignment: Alignment.centerLeft,
                child: Text(indexColumns[index]),
              ),
            );
          },
          rightSideItemBuilder: (context, index) {
            var row = rows[index];
            debugPrint(row.toString());
            debugPrint(index.toString());
            return Row(
                children: columns.map((c) {
              if (tablePageModel.editingRowIndex == index &&
                  tablePageModel.editingColumn.id == c.id &&
                  (EnumToString.fromString(ColumnType.values, c.type) ==
                          ColumnType.string ||
                      EnumToString.fromString(ColumnType.values, c.type) ==
                          ColumnType.integer)) {
                Function(String) onTextFieldChanged = (String text) {};
                List<TextInputFormatter> inputFormatters = [];

                if (EnumToString.fromString(ColumnType.values, c.type) ==
                    ColumnType.integer) {
                  onTextFieldChanged =
                      tablePageModel.onIntegerValueTextFieldChanged;
                  inputFormatters
                      .add(FilteringTextInputFormatter.allow(RegExp(r"[0-9]")));
                }

                return Container(
                  height: height,
                  width: width,
                  child: RawKeyboardListener(
                    focusNode: FocusNode(),
                    child: TextField(
                      focusNode: tablePageModel.focusMap[index]![c.id]!,
                      controller: tablePageModel.editingController,
                      onChanged: onTextFieldChanged,
                      inputFormatters: inputFormatters,
                      style: Theme.of(context).textTheme.bodyText1!,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        isDense: true,
                        hintText: "",
                        fillColor: Theme.of(context).cardColor,
                        filled: true,
                        contentPadding:
                            EdgeInsets.symmetric(vertical: 8, horizontal: 0),
                      ),
                    ),
                  ),
                );
              }
              return InkWell(
                  onTap: () {
                    debugPrint("tap cel");
                    tablePageModel.onTapCell(index, c, row[c.id]!);
                  },
                  hoverColor: Theme.of(context).hoverColor,
                  child: Container(
                      height: height,
                      width: width,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        row[c.id]!,
                        overflow: TextOverflow.ellipsis,
                      )));
            }).toList());
          },
        ),
      );
    }

    final slivers = [
      SliverList(
        delegate: SliverChildBuilderDelegate((context, index) {
          return table;
        }, childCount: 1),
      )
    ];
    if (headers.length > 1) {
      slivers.add(SliverList(
        delegate: SliverChildBuilderDelegate((context, index) {
          return ElevatedButton(
            onPressed: () {
              tablePageModel.onTapCreateRow();
            },
            child: Container(
                child: Row(
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Icon(CupertinoIcons.plus),
                ),
                Container(
                  padding: EdgeInsets.symmetric(vertical: 10),
                  child: Text(tr("table.add_row.button")),
                ),
              ],
            )),
          );
        }, childCount: 1),
      ));
    }

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(36),
        child: AppBar(
          title: Text(tablePageModel.node.name),
          actions: [
            IconButton(
                onPressed: () {
                  Navigator.of(context).push(
                    CupertinoPageRoute(builder: (ctx) {
                      return ChangeNotifierProvider(
                          create: (_) => AddColumnPageModel(
                              context, globalModel, tableBean!, node),
                          child: AddColumnPage());
                    }),
                  );
                },
                icon: Icon(CupertinoIcons.plus, size: 16)),
            IconButton(
                onPressed: () {}, icon: Icon(CupertinoIcons.table, size: 16)),
          ],
        ),
      ),
      body: GestureDetector(
        onTap: tablePageModel.onTapEmptyArea,
        child: Container(
          padding: EdgeInsets.symmetric(
            vertical: 3,
            horizontal: 10,
          ),
          child: BouncingScrollView(
            scrollBar: true,
            slivers: slivers,
          ),
        ),
      ),
    );
  }
}
