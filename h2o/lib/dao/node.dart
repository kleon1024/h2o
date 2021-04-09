import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:h2o/api/api.dart';
import 'package:h2o/bean/node.dart';
import 'package:h2o/model/global.dart';

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
      data: {"offset": 0, "limit": 10},
      options: this.globalModel!.userDao!.accessTokenOptions(),
    );

    if (nodes != null) {
      nodeMap[teamID] = nodes;
    }
  }

  @override
  void dispose() {
    super.dispose();
    if (!cancelToken.isCancelled) cancelToken.cancel();
  }
}
