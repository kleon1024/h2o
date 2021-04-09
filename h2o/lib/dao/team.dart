import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:h2o/api/api.dart';
import 'package:h2o/bean/team.dart';
import 'package:h2o/model/global.dart';

class TeamDao extends ChangeNotifier {
  BuildContext? context;
  List<TeamBean> teams = [];
  CancelToken cancelToken = CancelToken();
  GlobalModel? globalModel;

  setContext(BuildContext context, GlobalModel globalModel) async {
    if (this.context == null) {
      this.context = context;
      this.globalModel = globalModel;
      globalModel.teamDao = this;

      globalModel.registerCallback(
          EventType.FIRST_TIME_LOGIN_SUCCESS, updateTeams);
    }
  }

  Future updateTeams() async {
    List<TeamBean>? teams = await Api.listTeams(
      data: {"offset": 0, "limit": 1},
      options: this.globalModel!.userDao!.accessTokenOptions(),
    );

    if (teams != null) {
      this.teams = teams;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    super.dispose();
    if (!cancelToken.isCancelled) cancelToken.cancel();
  }
}
