import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:h2o/bean/node.dart';
import 'package:h2o/db/db.dart';
import 'package:h2o/global/constants.dart';
import 'package:h2o/model/global.dart';

enum NodeType {
  directory,
  channel,
  document,
  table,
}

class NodeDao extends ChangeNotifier {
  BuildContext? context;
  Map<String, List<NodeBean>> nodeMap = {};
  CancelToken cancelToken = CancelToken();
  GlobalModel? globalModel;

  setContext(BuildContext context, GlobalModel globalModel) async {
    if (this.context == null) {
      this.context = context;
      this.globalModel = globalModel;
      globalModel.nodeDao = this;

      this.loadNodes();
      // globalModel.registerCallback(EventType.TEAM_LIST_UPDATED, updateNodes);
      // globalModel.registerCallback(
      //     EventType.TEAM_SIDEBAR_INDEX_CHANGED, updateNodes);
    }
  }

  List<NodeBean> reorder(List<NodeBean> nodes) {
    List<NodeBean> reordered = [];
    Map<String, NodeBean> nodeMap = {};
    nodes.forEach((n) {
      nodeMap[n.previousId] = n;
      debugPrint(n.previousId + " : " + n.uuid);
    });
    String previousId = EMPTY_UUID;
    for (int i = 0; i < nodes.length; i++) {
      var n = nodeMap[previousId];
      if (n == null) {
        debugPrint("reorder nodes unexpected previous node id: " + previousId);
      } else {
        reordered.add(n);
        previousId = n.uuid;
      }
    }
    return reordered;
  }

  Future loadNodes() async {
    String teamId = "123";
    var nodes = await DBProvider.db.getNodes(teamId, EMPTY_UUID);
    this.nodeMap[teamId] = reorder(nodes);
    notifyListeners();
  }

  Future loadChildren(NodeBean node) async {
    String teamId = "123";
    var nodes = await DBProvider.db.getNodes(teamId, node.uuid);
    for (var n in nodes) {
      n.parent = node;
      debugPrint("loadChildren:" + n.uuid);
    }
    node.children = reorder(nodes);
    notifyListeners();
  }

  @override
  void dispose() {
    super.dispose();
    if (!cancelToken.isCancelled) cancelToken.cancel();
  }
}
