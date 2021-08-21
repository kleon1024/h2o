import 'package:enum_to_string/enum_to_string.dart';
import 'package:flutter/cupertino.dart';
import 'package:h2o/bean/column.dart';
import 'package:h2o/bean/node.dart';
import 'package:h2o/dao/table.dart';
import 'package:h2o/dao/transaction.dart';
import 'package:h2o/model/global.dart';
import 'package:h2o/model/table/table_page.dart';
import 'package:uuid/uuid.dart';

class AddColumnPageModel extends ChangeNotifier {
  BuildContext context;
  GlobalModel globalModel;
  TablePageModel tablePageModel;

  NodeBean node;

  AddColumnPageModel(
      this.context, this.globalModel, this.node, this.tablePageModel);

  TextEditingController controller = TextEditingController();
  ColumnType columnType = ColumnType.string;
  bool get isNameValid => controller.text.trim().isNotEmpty;
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
    notifyListeners();
  }

  onTapCreateColumn() async {
    String uuidString = Uuid().v4();
    ColumnBean columnBean = ColumnBean(
      uuid: uuidString,
      type: EnumToString.convertToString(columnType),
      name: controller.text.trim(),
      tableId: node.uuid,
      defaultValue: defaultValue,
    );
    this.globalModel.tableDao!.tableColumnMap[node.uuid]!.add(columnBean);
    this.globalModel.transactionDao!.transaction(Transaction([
          Operation(OperationType.InsertColumn,
              column: ColumnBean.fromJson(columnBean.toJson()))
        ]));
    var rows = this.globalModel.tableDao!.tableRowMap[node.uuid];
    if (rows == null) {
      rows = [];
    }

    Object defaultObject = defaultValue;
    if (columnType == ColumnType.integer) {
      defaultObject = int.parse(defaultValue);
    }

    rows.forEach((row) {
      row.values.add(defaultObject);
    });

    this.tablePageModel.refresh();
    Navigator.pop(this.context);
    notifyListeners();
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
