import 'package:direct_select/direct_select.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:enum_to_string/enum_to_string.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:h2o/bean/data_point.dart';
import 'package:h2o/components/blocks/chart_block.dart';
import 'package:h2o/components/scroll/bouncing_scroll_view.dart';
import 'package:h2o/dao/node.dart';
import 'package:h2o/model/document/add_chart_page.dart';
import 'package:h2o/model/global.dart';
import 'package:h2o/pages/channel/forward_to_doc.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class AddChartPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final globalModel = Provider.of<GlobalModel>(context);
    final addChartPageModel = Provider.of<AddChartPageModel>(context);

    var bodyTestStyle = Theme.of(context).textTheme.bodyText1!;
    if (!addChartPageModel.isNameValid) {
      bodyTestStyle =
          bodyTestStyle.merge(TextStyle(color: Theme.of(context).cardColor));
    }

    List<CartesianSeries> series = [];
    for (var s in addChartPageModel.chart.series) {
      switch (EnumToString.fromString(ChartSeriesType.values, s.type)) {
        case ChartSeriesType.line:
          series.add(LineSeries<DataPoint, Object>(
            dataSource: s.points,
            xValueMapper: (DataPoint point, _) => point.x,
            yValueMapper: (DataPoint point, _) => point.y,
          ));
          break;
        case ChartSeriesType.column:
          series.add(ColumnSeries<DataPoint, Object>(
            dataSource: s.points,
            xValueMapper: (DataPoint point, _) => point.x,
            yValueMapper: (DataPoint point, _) => point.y,
          ));
          break;
        default:
      }
    }

    debugPrint("rebuild ---");

    Widget selectDataSource = InkWell(
      onTap: () {
        Navigator.of(context).push(
          CupertinoPageRoute(builder: (ctx) {
            return ForwardToDocPage(
              type: NodeType.table,
              teamId: addChartPageModel.node.teamId,
              onCancel: () {},
              onConfirm: addChartPageModel.onSelectTableNode,
            );
          }),
        );
      },
      child: Container(
        height: 50,
        color: Theme.of(context).canvasColor,
        child: Row(
          children: [
            Expanded(
              child: Container(
                  padding: EdgeInsets.symmetric(vertical: 6, horizontal: 10),
                  child: Text(
                    addChartPageModel.tableNode == null
                        ? tr("doc.add_chart.select_data_source")
                        : addChartPageModel.tableNode!.name,
                    style: Theme.of(context).textTheme.bodyText1,
                  )),
            ),
            Icon(Icons.arrow_forward_ios_outlined, size: 16)
          ],
        ),
      ),
    );

    var slivers = [
      SliverList(
        delegate: SliverChildBuilderDelegate((context, index) {
          return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 15,
                ),
                Container(
                    padding: EdgeInsets.symmetric(vertical: 6, horizontal: 10),
                    child: Text(
                      tr("doc.add_chart.preview"),
                      style: Theme.of(context).textTheme.bodyText1,
                    ))
              ]);
        }, childCount: 1),
      ),
      SliverList(
        delegate: SliverChildBuilderDelegate((context, index) {
          return Container(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: SfCartesianChart(
              primaryXAxis: CategoryAxis(),
              // Chart title
              // title: ChartTitle(text: 'Half yearly sales analysis'),
              // Enable legend
              legend: Legend(isVisible: true, position: LegendPosition.bottom),
              series: series,
            ),
          );
        }, childCount: 1),
      ),
      SliverList(
        delegate: SliverChildBuilderDelegate((context, index) {
          return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                    padding: EdgeInsets.symmetric(vertical: 6, horizontal: 10),
                    child: Text(
                      tr("doc.add_chart.data_source"),
                      style: Theme.of(context).textTheme.bodyText1,
                    ))
              ]);
        }, childCount: 1),
      ),
      SliverList(
        delegate: SliverChildBuilderDelegate((context, index) {
          return selectDataSource;
        }, childCount: 1),
      ),
      SliverList(
        delegate: SliverChildBuilderDelegate((context, index) {
          return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                    padding: EdgeInsets.symmetric(vertical: 6, horizontal: 10),
                    child: Text(
                      tr("doc.add_chart.horizontal_axis"),
                      style: Theme.of(context).textTheme.bodyText1,
                    ))
              ]);
        }, childCount: 1),
      ),
      SliverList(
        delegate: SliverChildBuilderDelegate((context, index) {
          return addChartPageModel.horizontalColumns.length == 0
              ? selectDataSource
              : DirectSelect(
                  itemExtent: 35.0,
                  selectedIndex: addChartPageModel.selectedHorizontalIndex,
                  backgroundColor: Theme.of(context).canvasColor,
                  child: Container(
                    height: 50,
                    color: Theme.of(context).canvasColor,
                    child: Row(
                      children: [
                        Expanded(
                          child: Container(
                              padding: EdgeInsets.symmetric(
                                  vertical: 6, horizontal: 10),
                              child: Text(
                                addChartPageModel
                                    .horizontalColumns[addChartPageModel
                                        .selectedHorizontalIndex]
                                    .name,
                                style: Theme.of(context).textTheme.bodyText1,
                              )),
                        ),
                        Icon(CupertinoIcons.chevron_up_chevron_down, size: 16)
                      ],
                    ),
                  ),
                  onSelectedItemChanged:
                      addChartPageModel.onSelectHorizontalIndex,
                  items: addChartPageModel.horizontalColumns
                      .map((c) => Text(
                            c.name,
                            style: Theme.of(context).textTheme.bodyText1,
                          ))
                      .toList());
        }, childCount: 1),
      ),
      SliverList(
        delegate: SliverChildBuilderDelegate((context, index) {
          return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                    padding: EdgeInsets.symmetric(vertical: 6, horizontal: 10),
                    child: Text(
                      tr("doc.add_chart.vertical_axis"),
                      style: Theme.of(context).textTheme.bodyText1,
                    ))
              ]);
        }, childCount: 1),
      ),
      SliverList(
        delegate: SliverChildBuilderDelegate((context, index) {
          return addChartPageModel.verticalColumns.length == 0
              ? selectDataSource
              : DirectSelect(
                  itemExtent: 35.0,
                  selectedIndex: addChartPageModel.selectedVerticalIndex,
                  backgroundColor: Theme.of(context).canvasColor,
                  child: Container(
                    height: 50,
                    color: Theme.of(context).canvasColor,
                    child: Row(
                      children: [
                        Expanded(
                          child: Container(
                              padding: EdgeInsets.symmetric(
                                  vertical: 6, horizontal: 10),
                              child: Text(
                                addChartPageModel
                                    .verticalColumns[
                                        addChartPageModel.selectedVerticalIndex]
                                    .name,
                                style: Theme.of(context).textTheme.bodyText1,
                              )),
                        ),
                        Icon(CupertinoIcons.chevron_up_chevron_down, size: 16)
                      ],
                    ),
                  ),
                  onSelectedItemChanged:
                      addChartPageModel.onSelectVerticalIndex,
                  items: addChartPageModel.verticalColumns
                      .map((c) => Text(
                            c.name,
                            style: Theme.of(context).textTheme.bodyText1,
                          ))
                      .toList());
        }, childCount: 1),
      ),
      SliverList(
        delegate: SliverChildBuilderDelegate((context, index) {
          return Container(
            height: 150,
          );
        }, childCount: 1),
      ),
    ];

    return Scaffold(
      backgroundColor: Theme.of(context).cardColor,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(36),
        child: AppBar(
          automaticallyImplyLeading: false,
          elevation: 0,
          centerTitle: true,
          leading: InkWell(
              onTap: () {
                Navigator.pop(context);
              },
              child: Container(
                width: 64,
                child: Text(tr("doc.add_chart.cancel")),
                alignment: Alignment.center,
              )),
          backgroundColor: Theme.of(context).canvasColor,
          title: Text(tr("doc.add_chart.title"),
              style: Theme.of(context)
                  .textTheme
                  .bodyText1!
                  .merge(TextStyle(fontWeight: FontWeight.bold))),
          titleSpacing: 0.0,
          actions: [
            InkWell(
                onTap: addChartPageModel.isNameValid
                    ? addChartPageModel.onTapInsertChart
                    : null,
                child: Container(
                  width: 64,
                  child: Text(
                    tr("doc.add_chart.confirm"),
                    style: bodyTestStyle,
                  ),
                  alignment: Alignment.center,
                )),
          ],
        ),
      ),
      body: Container(
        child: BouncingScrollView(
          scrollBar: true,
          slivers: slivers,
        ),
      ),
    );
  }
}
