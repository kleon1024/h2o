import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:h2o/bean/column.dart';
import 'package:h2o/bean/node.dart';
import 'package:h2o/bean/select.dart';
import 'package:h2o/dao/transaction.dart';
import 'package:h2o/model/global.dart';
import 'package:h2o/model/table/table_page.dart';
import 'package:h2o/utils/color.dart';
import 'package:uuid/uuid.dart';

class SelectPageModel extends ChangeNotifier {
  BuildContext context;
  GlobalModel globalModel;
  TablePageModel tablePageModel;
  NodeBean node;
  ColumnBean column;

  SelectPageModel(this.context, this.globalModel, this.node, this.column,
      this.tablePageModel) {
    color = Color.fromRGBO(
        rng.nextInt(64) + 96, rng.nextInt(64) + 96, rng.nextInt(64) + 96, 1);
    matchedOptions = column.selects!;
  }

  final controller = TextEditingController();
  final focusNode = FocusNode();
  final rng = Random();
  late Color color;
  List<SelectBean> matchedOptions = [];
  bool exactlyMatched = false;

  onTextFieldChanged(String text) {
    debugPrint("\'" + text + "\'");
    matchedOptions = [];
    exactlyMatched = false;
    if (text.isEmpty) {
      matchedOptions = column.selects!;
    } else {
      for (var select in column.selects!) {
        debugPrint(select.text + ":" + text);
        if (select.text.startsWith(text)) {
          matchedOptions.add(select);
        }
        if (select.text == text) {
          exactlyMatched = true;
        }
      }
    }
    notifyListeners();
  }

  onCreateSelect() {
    String uuidString = Uuid().v4();
    SelectBean select = SelectBean(
      uuid: uuidString,
      text: controller.text.trim(),
      color: ColorUtil.ColorToInt(color),
      columnId: column.uuid,
    );
    debugPrint("color:" + color.toString());
    debugPrint("color:" +
        ColorUtil.ColorFromInt(ColorUtil.ColorToInt(color)).toString());
    column.selects!.add(select);
    this.globalModel.transactionDao!.transaction(Transaction([
          Operation(OperationType.InsertSelect,
              select: SelectBean.fromJson(select.toJson()))
        ]));
    controller.text = "";
    matchedOptions = column.selects!;
    notifyListeners();
  }
}
