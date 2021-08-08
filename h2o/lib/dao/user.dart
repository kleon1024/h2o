import 'dart:async';

import 'package:dio/dio.dart';
import 'package:enum_to_string/enum_to_string.dart';
import 'package:flutter/cupertino.dart';
import 'package:h2o/api/api.dart';
import 'package:h2o/bean/token.dart';
import 'package:h2o/bean/user.dart';
import 'package:h2o/global/enum.dart';
import 'package:h2o/model/global.dart';
import 'package:h2o/utils/local_storage.dart';

class UserDao extends ChangeNotifier {
  BuildContext? context;
  UserBean? user;
  CancelToken cancelToken = CancelToken();
  GlobalModel? globalModel;

  setContext(BuildContext context, GlobalModel globalModel) async {
    if (this.context == null) {
      this.context = context;
      this.globalModel = globalModel;
      globalModel.userDao = this;

      var json = await LocalStorage.getJson(StorageKey.USER);
      UserBean? userBean;
      if (json != null) {
        userBean = UserBean.fromJson(json);
      }
      if (userBean != null) {
        this.user = userBean;
      }
      this.refresh();
      // if (this.user == null) {
      //   debugPrint("create anonymous user");
      //   await this.createAnonymousUser();
      // } else {
      //   debugPrint("refresh token");
      //   await this.refreshToken();
      // }

      if (this.user == null) {
        this.user = UserBean(
            id: "123",
            name: "test",
            accessToken: TokenBean(token: "", expiresAt: ""),
            refreshToken: TokenBean(token: "", expiresAt: ""));
      }

      if (this.isLogin()) {
        debugPrint("login as " + this.user!.id);
      } else {
        debugPrint("login failed");
      }

      if (this.isLogin()) {
        this.globalModel!.triggerCallback(EventType.FIRST_TIME_LOGIN_SUCCESS);
      }
    }
  }

  bool isLogin() {
    return this.user != null;
  }

  Options accessTokenOptions() {
    if (this.user != null) {
      return Options(
          headers: {'Authorization': 'Bearer ' + this.user!.accessToken.token});
    }
    return Options();
  }

  Options refreshTokenOptions() {
    if (this.user != null) {
      return Options(headers: {
        'Authorization': 'Bearer ' + this.user!.refreshToken.token
      });
    }
    return Options();
  }

  createAnonymousUser() async {
    UserBean? userBean = await Api.createUser(
        data: {"type": EnumToString.convertToString(UserType.anonymous)});
    if (userBean != null) {
      this.user = userBean;
      debugPrint(userBean.id.toString());
      await LocalStorage.setJson(StorageKey.USER, userBean.toJson());
      this.setupRefreshTimer();
    }
  }

  refreshToken() async {
    UserBean? userBean = await Api.refreshToken(
      data: {"type": EnumToString.convertToString(UserType.anonymous)},
      options: refreshTokenOptions(),
    );
    if (userBean != null) {
      this.user = userBean;
      debugPrint(userBean.id.toString());
      await LocalStorage.setJson(StorageKey.USER, userBean.toJson());
      this.setupRefreshTimer();
    }
  }

  setupRefreshTimer() async {
    var duration = DateTime.parse(this.user!.accessToken.expiresAt)
            .difference(DateTime.now().toUtc()) -
        Duration(minutes: 30);
    debugPrint("Setup a timer with minutes:" + duration.inMinutes.toString());
    if (duration.isNegative) return;
    Timer(duration, () async {
      await this.refreshToken();
    });
  }

  @override
  void dispose() {
    super.dispose();
    if (!cancelToken.isCancelled) cancelToken.cancel();
  }

  refresh() {
    notifyListeners();
  }
}
