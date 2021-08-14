import 'package:flutter/material.dart';
import 'package:h2o/bean/block.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

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
    return Container(
        child: SfCartesianChart(
            primaryXAxis: CategoryAxis(),
            // Chart title
            // title: ChartTitle(text: 'Half yearly sales analysis'),
            // Enable legend
            legend: Legend(isVisible: true, position: LegendPosition.bottom),
            series: <LineSeries<SalesData, String>>[
          LineSeries<SalesData, String>(
            dataSource: <SalesData>[
              SalesData('Jan', 35),
              SalesData('Feb', 28),
              SalesData('Mar', 34),
              SalesData('Apr', 32),
              SalesData('May', 40)
            ],
            xValueMapper: (SalesData sales, _) => sales.year,
            yValueMapper: (SalesData sales, _) => sales.sales,
            // Enable data label
            dataLabelSettings: DataLabelSettings(isVisible: true),
          ),
          LineSeries<SalesData, String>(
            dataSource: <SalesData>[
              SalesData('Jan', 45),
              SalesData('Feb', 38),
              SalesData('Mar', 24),
              SalesData('Apr', 42),
              SalesData('May', 20)
            ],
            xValueMapper: (SalesData sales, _) => sales.year,
            yValueMapper: (SalesData sales, _) => sales.sales,
            // Enable data label
            dataLabelSettings: DataLabelSettings(isVisible: true),
          ),
        ]));
  }
}
