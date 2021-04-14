import 'package:flutter/cupertino.dart';
import 'package:h2o/bean/node.dart';
import 'package:h2o/model/global.dart';
import 'package:provider/provider.dart';

class TablePageModel extends ChangeNotifier {
  BuildContext context;
  GlobalModel globalModel;

  NodeBean node;

  TablePageModel(this.context, this.node)
      : globalModel = Provider.of<GlobalModel>(context) {
    this.globalModel.tableDao!.updateTables(node);
  }

  final controller = TextEditingController();
  final Map<String, Map<String, FocusNode>> focusMap = {};
}
