import 'package:flutter/cupertino.dart';
import 'package:h2o/model/global.dart';

class NavigationPageModel extends ChangeNotifier {
  BuildContext? context;
  GlobalModel? globalModel;

  int currentTeamIndex = 0;

  setContext(BuildContext context, GlobalModel globalModel) {
    if (this.context == null) {
      this.context = context;
      this.globalModel = globalModel;
      globalModel.navigationPageModel = this;
      this.globalModel!.registerCallback(EventType.NODE_CREATED, refresh);
    }
  }

  Future refresh() async {
    notifyListeners();
  }

  onTapTeamIcon(int index) {
    this.currentTeamIndex = index;
    notifyListeners();
    this.globalModel!.triggerCallback(EventType.TEAM_SIDEBAR_INDEX_CHANGED);
  }
}
