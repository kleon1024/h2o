import 'package:enum_to_string/enum_to_string.dart';
import 'package:flutter/cupertino.dart';
import 'package:h2o/bean/chart.dart';
import 'package:h2o/bean/chart_series.dart';
import 'package:h2o/bean/column.dart';
import 'package:h2o/bean/data_point.dart';
import 'package:h2o/bean/node.dart';
import 'package:h2o/bean/row.dart';
import 'package:h2o/components/blocks/chart_block.dart';
import 'package:h2o/dao/node.dart';
import 'package:h2o/dao/table.dart';
import 'package:h2o/db/db.dart';
import 'package:h2o/model/global.dart';

class AddChartPageModel extends ChangeNotifier {
  BuildContext context;
  GlobalModel globalModel;

  final NodeBean node;
  final ChartSeriesType type;
  NodeBean? tableNode;
  final Function(ChartBean chart)? onSubmit;

  AddChartPageModel(this.node, this.type, this.context, this.globalModel,
      {this.onSubmit});

  TextEditingController controller = TextEditingController();
  NodeType nodeType = NodeType.directory;
  ChartBean chart = ChartBean(table: "", series: []);
  int selectedHorizontalIndex = 0;
  int selectedVerticalIndex = 0;

  bool get isNameValid =>
      this.tableNode != null &&
      this.chart.series.length > 0 &&
      this.chart.series[0].x != "" &&
      this.chart.series[0].y != "";

  List<ColumnBean> get horizontalColumns => () {
        List<ColumnBean> columns = [];
        if (tableNode != null &&
            this
                .globalModel
                .tableDao!
                .tableColumnMap
                .containsKey(tableNode!.uuid)) {
          List<ColumnBean> rawColumns =
              this.globalModel.tableDao!.tableColumnMap[tableNode!.uuid]!;
          String columnTypeInteger =
              EnumToString.convertToString(ColumnType.integer);
          String columnTypeString =
              EnumToString.convertToString(ColumnType.string);
          for (var c in rawColumns) {
            if (c.type == columnTypeInteger || c.type == columnTypeString) {
              columns.add(c);
            }
          }
        }

        return columns;
      }();

  List<ColumnBean> get verticalColumns => () {
        List<ColumnBean> columns = [];
        if (tableNode != null &&
            this
                .globalModel
                .tableDao!
                .tableColumnMap
                .containsKey(tableNode!.uuid)) {
          List<ColumnBean> rawColumns =
              this.globalModel.tableDao!.tableColumnMap[tableNode!.uuid]!;
          String columnTypeInteger =
              EnumToString.convertToString(ColumnType.integer);
          for (var c in rawColumns) {
            if (c.type == columnTypeInteger) {
              columns.add(c);
            }
          }
        }

        return columns;
      }();

  void onSelectHorizontalIndex(int? index) {
    if (index != null && this.selectedHorizontalIndex != index) {
      this.selectedHorizontalIndex = index;
      refreshChart();
    }
    notifyListeners();
  }

  void onSelectVerticalIndex(int? index) {
    if (index != null && this.selectedVerticalIndex != index) {
      this.selectedVerticalIndex = index;
      refreshChart();
    }
    notifyListeners();
  }

  onNodeTypeRadioChanged(NodeType? value) {
    this.nodeType = value!;
    notifyListeners();
  }

  onTapInsertChart() {
    if (this.onSubmit != null) {
      this.onSubmit!(this.chart);
    }
    Navigator.of(context).pop();
  }

  onSelectTableNode(NodeBean node) async {
    this.tableNode = node;
    this.chart.table = node.uuid;
    notifyListeners();
    if (!this
        .globalModel
        .tableDao!
        .tableColumnMap
        .containsKey(tableNode!.uuid)) {
      await this.globalModel.tableDao!.loadTables(tableNode!);
    }
    await refreshChart();
    notifyListeners();
  }

  refreshChart() async {
    String type = EnumToString.convertToString(this.type);
    String x = "";
    String y = "";
    var horizontalColumns = this.horizontalColumns;
    if (horizontalColumns.length > 0) {
      x = horizontalColumns[selectedHorizontalIndex].uuid;
    }
    var verticalColumns = this.verticalColumns;
    if (verticalColumns.length > 0) {
      y = verticalColumns[selectedVerticalIndex].uuid;
    }

    if (this.chart.series.length == 0) {
      this.chart.series.add(ChartSeries(type: type, x: x, y: y, points: []));
    } else {
      this.chart.series[0] = ChartSeries(type: type, x: x, y: y, points: []);
    }

    for (var s in this.chart.series) {
      debugPrint(s.x + ":" + s.y);
      List<RowBean> rows = await DBProvider.db.getRows(chart.table, [s.x, s.y]);
      for (var r in rows) {
        debugPrint(r.values[0].toString() + "," + r.values[1].toString());
        s.points.add(DataPoint(x: r.values[0], y: r.values[1] as num));
      }
    }
    notifyListeners();
  }
}
