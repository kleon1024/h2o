import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:h2o/bean/node.dart';
import 'package:h2o/db/db.dart';
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

  Future loadNodes() async {
    var nodes = await DBProvider.db.getNodes();
    this.nodeMap["123"] = nodes;
  }

  // Future updateNodes() async {
  //   var teams = this.globalModel!.teamDao!.teams;
  //   if (teams.length < 1) {
  //     return;
  //   }
  //   String teamID =
  //       teams[this.globalModel!.navigationPageModel!.currentTeamIndex].id;
  //   List<NodeBean>? nodes = await Api.listTeamNodes(
  //     teamID,
  //     data: {"offset": 0, "limit": 100},
  //     options: this.globalModel!.userDao!.accessTokenOptions(),
  //   );
  //
  //   if (nodes != null) {
  //     if (nodes.length == 0) {
  //       nodeMap[teamID] = [];
  //       return;
  //     }
  //     Map<String, NodeBean> preNodeMap = {};
  //     nodes.forEach((node) {
  //       preNodeMap[node.preNodeID] = node;
  //     });
  //     debugPrint(preNodeMap.toString());
  //     NodeBean node = preNodeMap[EMPTY_UUID]!;
  //     int cnt = 0;
  //     List<NodeBean> orderedNodes = [];
  //     while (node.posNodeID != EMPTY_UUID) {
  //       cnt += 1;
  //       if (cnt >= nodes.length) {
  //         break;
  //       }
  //       orderedNodes.add(node);
  //       node = preNodeMap[node.id]!;
  //     }
  //     orderedNodes.add(node);
  //     nodeMap[teamID] = orderedNodes;
  //   }
  // }

  @override
  void dispose() {
    super.dispose();
    if (!cancelToken.isCancelled) cancelToken.cancel();
  }
}
