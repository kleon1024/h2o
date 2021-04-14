import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:h2o/api/api.dart';
import 'package:h2o/bean/node.dart';
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

      globalModel.registerCallback(EventType.TEAM_LIST_UPDATED, updateNodes);
      globalModel.registerCallback(
          EventType.TEAM_SIDEBAR_INDEX_CHANGED, updateNodes);
      globalModel.registerCallback(EventType.NODE_CREATED, updateNodes);
    }
  }

  Future updateNodes() async {
    var teams = this.globalModel!.teamDao!.teams;
    if (teams.length < 1) {
      return;
    }
    String teamID =
        teams[this.globalModel!.navigationPageModel!.currentTeamIndex].id;
    List<NodeBean>? nodes = await Api.listTeamNodes(
      teamID,
      data: {"offset": 0, "limit": 100},
      options: this.globalModel!.userDao!.accessTokenOptions(),
    );

    if (nodes != null) {
      if (nodes.length == 0) {
        nodeMap[teamID] = [];
        return;
      }
      Map<String, NodeBean> preNodeMap = {};
      nodes.forEach((node) {
        preNodeMap[node.preNodeID] = node;
      });
      debugPrint(preNodeMap.toString());
      NodeBean node = preNodeMap[EMPTY_UUID]!;
      int cnt = 0;
      List<NodeBean> orderedNodes = [];
      while (node.posNodeID != EMPTY_UUID) {
        cnt += 1;
        if (cnt >= nodes.length) {
          break;
        }
        orderedNodes.add(node);
        node = preNodeMap[node.id]!;
      }
      orderedNodes.add(node);
      nodeMap[teamID] = orderedNodes;
    }
  }

  @override
  void dispose() {
    super.dispose();
    if (!cancelToken.isCancelled) cancelToken.cancel();
  }
}
