import 'package:enum_to_string/enum_to_string.dart';
import 'package:flutter/cupertino.dart';
import 'package:h2o/api/api.dart';
import 'package:h2o/bean/column.dart';
import 'package:h2o/bean/node.dart';
import 'package:h2o/bean/table.dart';
import 'package:h2o/dao/table.dart';
import 'package:h2o/model/global.dart';
import 'package:uuid/uuid.dart';

class AddColumnPageModel extends ChangeNotifier {
  BuildContext context;
  GlobalModel globalModel;

  TableBean table;
  NodeBean node;

  AddColumnPageModel(this.context, this.globalModel, this.table, this.node);

  TextEditingController controller = TextEditingController();
  ColumnType columnType = ColumnType.string;
  bool isNameValid = false;
  String defaultValue = "";
  TextEditingController defaultValueController = TextEditingController();

  onColumnTypeRadioChanged(ColumnType? value) {
    this.columnType = value!;
    switch (this.columnType) {
      case ColumnType.string:
        defaultValue = "";
        break;
      case ColumnType.integer:
        defaultValue = "0";
        break;
      case ColumnType.date:
        defaultValue = DateTime.now().toString();
        break;
      default:
        defaultValue = "";
    }
    defaultValueController.text = defaultValue;
    debugPrint("defaultValue:" + defaultValue.toString());
    notifyListeners();
  }

  onTextFieldChanged(String text) {
    text = text.trimLeft();
    if (text.endsWith(" ")) {
      text = text.substring(0, text.length - 1) + "-";
    }
    text = text.replaceAll(" ", "");
    isNameValid = text.isNotEmpty;
    controller.text = text;
    controller.selection = TextSelection.fromPosition(
        TextPosition(offset: controller.text.length));
    notifyListeners();
  }

  onTapCreateColumn() async {
    String uuidString = Uuid().v4();
    ColumnBean? columnBean = ColumnBean(
      id: uuidString,
      type: EnumToString.convertToString(columnType),
      name: controller.text,
      defaultValue: defaultValue,
    );
    this.globalModel.tableDao!.tableMap[node.id]!.columns.add(columnBean);
    var rows = this.globalModel.tableDao!.tableRowMap[node.id];
    if (rows == null) {
      rows = [];
    }
    rows.forEach((row) {
      row[columnBean!.id] = defaultValue;
    });

    this.globalModel.triggerCallback(EventType.COLUMN_CREATED);
    Navigator.pop(this.context);

    columnBean = await Api.createColumn(
      table.id,
      data: {
        "id": uuidString,
        "name": controller.text,
        "type": EnumToString.convertToString(columnType),
        "defaultValue": defaultValue,
      },
      options: this.globalModel.userDao!.accessTokenOptions(),
    );
    if (columnBean != null) {}
  }

  onDefaultIntegerValueTextFieldChanged(String text) {
    if (text.isEmpty) {
      text = "0";
    }
    while (text.length > 1 && text.startsWith("0")) {
      text = text.substring(1);
    }
    defaultValueController.text = text;
    defaultValueController.selection = TextSelection.fromPosition(
        TextPosition(offset: defaultValueController.text.length));
    defaultValue = text;
    notifyListeners();
  }

  onDefaultStringValueTextFieldChanged(String text) {
    defaultValue = text;
  }
}
