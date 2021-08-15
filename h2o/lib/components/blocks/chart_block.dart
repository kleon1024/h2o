import 'package:enum_to_string/enum_to_string.dart';
import 'package:flutter/material.dart';
import 'package:h2o/bean/block.dart';
import 'package:h2o/bean/chart.dart';
import 'package:h2o/bean/data_point.dart';
import 'package:h2o/dao/block.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

enum ChartSeriesType {
  line,
  column,
}

class SalesData {
  SalesData(this.year, this.sales);
  final String year;
  final double sales;
}

class ChartBlock extends StatelessWidget {
  final BlockBean block;
  const ChartBlock(this.block);

  @override
  Widget build(BuildContext context) {
    final blockDao = Provider.of<BlockDao>(context);

    if (!blockDao.chartBlockMap.containsKey(block.uuid)) {
      blockDao.loadChartData(block);
      return Container(child: SfCartesianChart(primaryXAxis: CategoryAxis()));
    }

    ChartBean chart = blockDao.chartBlockMap[block.uuid]!;
    List<CartesianSeries> series = [];
    for (var s in chart.series) {
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
    return Container(
        child: SfCartesianChart(
      primaryXAxis: CategoryAxis(),
      // Chart title
      // title: ChartTitle(text: 'Half yearly sales analysis'),
      // Enable legend
      legend: Legend(isVisible: true, position: LegendPosition.bottom),
      series: series,
    ));
  }
}
