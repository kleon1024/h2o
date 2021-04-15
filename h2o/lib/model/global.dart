import 'package:flutter/cupertino.dart';
import 'package:h2o/dao/block.dart';
import 'package:h2o/dao/node.dart';
import 'package:h2o/dao/table.dart';
import 'package:h2o/dao/team.dart';
import 'package:h2o/dao/user.dart';
import 'package:h2o/model/navigation_page.dart';

enum EventType {
  FIRST_TIME_LOGIN_SUCCESS,
  REFRESH_TOKEN_SUCCESS,
  TEAM_SIDEBAR_INDEX_CHANGED,
  TEAM_LIST_UPDATED,
  NODE_CREATED,
  NODE_BLOCKS_UPDATED,
  COLUMN_CREATED,
}

class GlobalModel extends ChangeNotifier {
  BuildContext? context;
  UserDao? userDao;
  TeamDao? teamDao;
  NodeDao? nodeDao;
  BlockDao? blockDao;
  TableDao? tableDao;

  Map<EventType, List<Future Function()>> callbackRegistry = {};

  NavigationPageModel? navigationPageModel;

  setContext(BuildContext context) {
    if (this.context == null) {
      this.context = context;
    }
  }

  Future refresh() async {
    notifyListeners();
  }

  void registerCallback(EventType type, Future Function() func) {
    if (this.callbackRegistry.containsKey(type)) {
      this.callbackRegistry[type]!.add(func);
    } else {
      this.callbackRegistry[type] = [func];
    }
  }

  void triggerCallback(EventType type) {
    if (this.callbackRegistry.containsKey(type)) {
      List<Future> futures = [];
      for (var func in this.callbackRegistry[type]!) {
        futures.add(func());
      }
      Future.wait(futures).then((_) {
        notifyListeners();
      });
    }
  }
}
