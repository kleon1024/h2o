import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:h2o/components/scroll/bouncing_scroll_view.dart';
import 'package:horizontal_data_table/horizontal_data_table.dart';

class TablePage extends StatelessWidget {
  var firstColumns = ["Research", "Coding", "Design", "Test"];
  var otherColumns = [
    ["100", "待处理"],
    ["200", "设计中"],
    ["300", "开发中"],
    ["400", "已发布"]
  ];

  @override
  Widget build(BuildContext context) {
    var table = HorizontalDataTable(
        leftHandSideColBackgroundColor: Colors.transparent,
        rightHandSideColBackgroundColor: Colors.transparent,
        isFixedHeader: true,
        leftHandSideColumnWidth: 100,
        rightHandSideColumnWidth: 600,
        itemCount: firstColumns.length,
        headerWidgets: [
          InkWell(
              hoverColor: Theme.of(context).hoverColor,
              onTap: () {},
              child: Container(
                height: 30,
                alignment: Alignment.centerLeft,
                child: Text("Name"),
              )),
          Expanded(
              child: InkWell(
                  hoverColor: Theme.of(context).hoverColor,
                  onTap: () {},
                  child: Container(
                    height: 30,
                    alignment: Alignment.centerLeft,
                    child: Text("Number"),
                  ))),
          Expanded(
              child: InkWell(
                  hoverColor: Theme.of(context).hoverColor,
                  onTap: () {},
                  child: Container(
                    height: 30,
                    alignment: Alignment.centerLeft,
                    child: Text("Progress"),
                  ))),
        ],
        leftSideItemBuilder: (context, index) {
          return InkWell(
            onTap: () {},
            hoverColor: Theme.of(context).hoverColor,
            child: Container(
              height: 30,
              alignment: Alignment.centerLeft,
              child: Text(firstColumns[index]),
            ),
          );
        },
        rightSideItemBuilder: (context, index) {
          var row = otherColumns[index];
          return Row(
            children: [
              Expanded(
                  child: InkWell(
                      onTap: () {},
                      hoverColor: Theme.of(context).hoverColor,
                      child: Container(
                          height: 30,
                          alignment: Alignment.centerLeft,
                          child: Text(row[0])))),
              Expanded(
                  child: InkWell(
                      onTap: () {},
                      hoverColor: Theme.of(context).hoverColor,
                      child: Container(
                          height: 30,
                          alignment: Alignment.centerLeft,
                          child: Text(row[1])))),
            ],
          );
        });

    return Scaffold(
        appBar: AppBar(
          title: Text(tr("app.title")),
          actions: [
            IconButton(onPressed: () {}, icon: Icon(CupertinoIcons.search)),
            IconButton(onPressed: () {}, icon: Icon(CupertinoIcons.table)),
          ],
        ),
        body: BouncingScrollView(
          scrollBar: true,
          slivers: [
            SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
                return Container(
                    width: 700,
                    height: 5 * 30 + 10,
                    padding: EdgeInsets.symmetric(
                      vertical: 3,
                      horizontal: 20,
                    ),
                    child: table);
              }, childCount: 1),
            ),
          ],
        ));
  }
}
