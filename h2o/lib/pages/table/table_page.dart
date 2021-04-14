import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:h2o/components/scroll/bouncing_scroll_view.dart';
import 'package:h2o/dao/table.dart';
import 'package:h2o/model/table/table_page.dart';
import 'package:horizontal_data_table/horizontal_data_table.dart';
import 'package:provider/provider.dart';

class TablePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final tablePageModel = Provider.of<TablePageModel>(context);
    final tableDao = Provider.of<TableDao>(context);
    List<List<String>> rows = [];
    List headers = [];
    String nodeID = tablePageModel.node.id;
    if (tableDao.tableMap.containsKey(nodeID)) {
      headers.addAll(tableDao.tableMap[nodeID]!.columns.map((c) => c.name));
    }
    if (tableDao.tableRowMap.containsKey(nodeID)) {
      rows.addAll(tableDao.tableRowMap[nodeID]!);
    }
    List indexColumns =
        List<String>.generate(rows.length, (index) => index.toString());
    debugPrint("rows:" + rows.toString());
    debugPrint("headers:" + headers.toString());
    debugPrint("indexColumns:" + indexColumns.toString());

    var table;

    if (headers.length == 0) {
      table = Container(
          height: MediaQuery.of(context).size.height,
          child: Center(
              child: ElevatedButton.icon(
            onPressed: () {},
            icon: Icon(CupertinoIcons.plus, size: 16),
            label: Text(tr("team.table.add_column.button")),
          )));
    } else {
      headers.insert(0, "");

      table = Container(
          width: 700,
          height: rows.length * 30 + 20,
          padding: EdgeInsets.symmetric(
            vertical: 3,
            horizontal: 10,
          ),
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
                        height: 30,
                        alignment: Alignment.centerLeft,
                        child: Text("id"),
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
              }));
    }

    return Scaffold(
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(36),
          child: AppBar(
            title: Text(tr("app.title")),
            actions: [
              IconButton(onPressed: () {}, icon: Icon(CupertinoIcons.search)),
              IconButton(onPressed: () {}, icon: Icon(CupertinoIcons.table)),
            ],
          ),
        ),
        body: BouncingScrollView(
          scrollBar: true,
          slivers: [
            SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
                return table;
              }, childCount: 1),
            ),
          ],
        ));
  }
}
