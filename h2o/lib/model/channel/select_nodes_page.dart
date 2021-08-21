import 'package:enum_to_string/enum_to_string.dart';
import 'package:flutter/cupertino.dart';
import 'package:h2o/bean/node.dart';
import 'package:h2o/dao/node.dart';
import 'package:h2o/db/db.dart';
import 'package:h2o/model/global.dart';

class SelectNodesPageModel extends ChangeNotifier {
  BuildContext context;
  GlobalModel globalModel;
  NodeType type;
  String teamId;

  SelectNodesPageModel(this.context, this.globalModel,
      {required this.type, required this.teamId}) {
    this.loadNodes();
  }

  List<NodeBean> nodes = [];

  loadNodes() async {
    this.nodes = await DBProvider.db
        .getPlainNodes(teamId, EnumToString.convertToString(type));
    notifyListeners();
  }
}
