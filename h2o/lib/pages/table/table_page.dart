import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:h2o/bean/node.dart';
import 'package:h2o/bean/table.dart';
import 'package:h2o/components/scroll/bouncing_scroll_view.dart';
import 'package:h2o/dao/table.dart';
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
    List<List<String>> rows = [];
    List headers = [];
    NodeBean node = tablePageModel.node;
    TableBean? tableBean;
    debugPrint("buildTablePage");
    if (tableDao.tableMap.containsKey(node.id)) {
      headers.addAll(tableDao.tableMap[node.id]!.columns.map((c) => c.name));
      tableBean = tableDao.tableMap[node.id];
    }
    if (tableDao.tableRowMap.containsKey(node.id)) {
      rows.addAll(tableDao.tableRowMap[node.id]!);
    }
    List indexColumns =
        List<String>.generate(rows.length, (index) => index.toString());
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
                            create: (_) => AddColumnPageModel(tableBean!, node),
                            child: AddColumnPage());
                      }),
                    );
                  },
            icon: Icon(CupertinoIcons.plus),
            label: Text(tr("table.add_column.button")),
          )));
    } else {
      headers.insert(0, "#");

      table = Container(
        // width: 700,
        height: (rows.length + 1) * 15 + 10,
        child: HorizontalDataTable(
          leftHandSideColBackgroundColor: Colors.transparent,
          rightHandSideColBackgroundColor: Colors.transparent,
          isFixedHeader: true,
          leftHandSideColumnWidth: 20,
          rightHandSideColumnWidth: 150,
          itemCount: rows.length,
          headerWidgets: headers
              .map((h) => InkWell(
                  hoverColor: Theme.of(context).hoverColor,
                  onTap: () {},
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      vertical: 3,
                      horizontal: 3,
                    ),
                    alignment: Alignment.centerLeft,
                    child: Text(h),
                  )))
              .toList(),
          leftSideItemBuilder: (context, index) {
            return InkWell(
              onTap: () {},
              hoverColor: Theme.of(context).hoverColor,
              child: Container(
                height: 30,
                alignment: Alignment.centerLeft,
                child: Text(indexColumns[index]),
              ),
            );
          },
          rightSideItemBuilder: (context, index) {
            var row = rows[index];
            return Row(
                children: rows[index]
                    .map((v) => InkWell(
                        onTap: () {},
                        hoverColor: Theme.of(context).hoverColor,
                        child: Container(
                            height: 30,
                            alignment: Alignment.centerLeft,
                            child: Text(v))))
                    .toList());
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
          return ElevatedButton.icon(
            onPressed: () {},
            icon: Icon(CupertinoIcons.plus),
            label: Text(tr("table.add_row.button")),
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
                          create: (_) => AddColumnPageModel(tableBean!, node),
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
      body: Container(
        padding: EdgeInsets.symmetric(
          vertical: 3,
          horizontal: 10,
        ),
        child: BouncingScrollView(
          scrollBar: true,
          slivers: slivers,
        ),
      ),
    );
  }
}
