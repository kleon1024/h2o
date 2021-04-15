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
  BuildContext? context;
  GlobalModel? globalModel;

  TableBean table;
  NodeBean node;

  AddColumnPageModel(this.table, this.node);

  TextEditingController controller = TextEditingController();
  ColumnType columnType = ColumnType.string;
  bool isNameValid = false;

  setContext(BuildContext context, globalModel) {
    if (this.context == null) {
      this.context = context;
      this.globalModel = globalModel;
    }
  }

  onColumnTypeRadioChanged(ColumnType? value) {
    this.columnType = value!;
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
        name: controller.text);
    this.globalModel!.tableDao!.tableMap[node.id]!.columns.add(columnBean);
    debugPrint(
        this.globalModel!.tableDao!.tableMap[node.id]!.columns.toString());
    notifyListeners();
    Navigator.pop(this.context!);

    columnBean = await Api.createColumn(
      table.id,
      data: {
        "id": uuidString,
        "name": controller.text,
        "type": EnumToString.convertToString(columnType),
      },
      options: this.globalModel!.userDao!.accessTokenOptions(),
    );
    if (columnBean != null) {}
  }
}
