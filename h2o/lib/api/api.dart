import 'package:dio/dio.dart';
import 'package:enum_to_string/enum_to_string.dart';
import 'package:flutter/cupertino.dart';
import 'package:h2o/bean/block.dart';
import 'package:h2o/bean/column.dart';
import 'package:h2o/bean/node.dart';
import 'package:h2o/bean/response.dart';
import 'package:h2o/bean/table.dart';
import 'package:h2o/bean/team.dart';
import 'package:h2o/bean/user.dart';

enum HttpMethod {
  GET,
  POST,
  PUT,
  DELETE,
  PATCH,
}

class Api {
  static final _client = Dio();
  // static IOWebSocketChannel? _wsIO;
  // static HtmlWebSocketChannel? _wsHtml;

  // static ws() {
  //   if (PlatformInfo().isWeb()) {
  //     return _wsHtml;
  //   } else {
  //     return _wsIO;
  //   }
  // }

  static initialize() {
    _client.options.baseUrl = "http://127.0.0.1:8000";
    _client.options.connectTimeout = 10 * 1000; // 10s
    _client.options.receiveTimeout = 15 * 1000; // 15s
    _client.interceptors.add(LogInterceptor(
      responseBody: true,
      requestHeader: false,
      requestBody: true,
      responseHeader: false,
      request: false,
    ));

    // if (PlatformInfo().isWeb()) {
    //   debugPrint("connect to ws");
    //   _wsHtml = HtmlWebSocketChannel.connect(
    //       Uri.parse("ws://127.0.0.1:8000/api/v1/ws"));
    // } else {
    //   _wsIO = IOWebSocketChannel.connect(
    //       Uri.parse("ws://127.0.0.1:8000/api/v1/ws"));
    // }
    // _ws?.stream.listen((message) {
    //   debugPrint(message);
    // });
  }

  Dio get client => _client;

  static String getBaseUrl() {
    return _client.options.baseUrl;
  }

  static Future<ResponseBean?> request(
    HttpMethod method,
    String url, {
    Map<String, dynamic>? data,
    CancelToken? cancelToken,
    Options? options,
  }) async {
    if (options != null) {
      options.method = EnumToString.convertToString(method);
    } else {
      options = Options(method: EnumToString.convertToString(method));
    }

    Map<String, dynamic>? queryParameters;
    if (method == HttpMethod.GET) {
      queryParameters = data;
      data = null;
    }

    var response;
    try {
      response = await _client.request(url,
          data: data, queryParameters: queryParameters, options: options);
    } catch (e) {
      return null;
    }
    if (response != null) {
      ResponseBean resp = ResponseBean.fromJson(response.data);
      return resp;
    }
  }

  // APIs
  static Future<UserBean?> createUser(
      {Map<String, dynamic>? data,
      CancelToken? cancelToken,
      Options? options}) async {
    ResponseBean? response = await request(HttpMethod.POST, '/api/v1/users',
        data: data, cancelToken: cancelToken, options: options);
    if (response != null && response.errorCode == 0) {
      return UserBean.fromJson(response.data);
    }
  }

  static Future<UserBean?> refreshToken(
      {Map<String, dynamic>? data,
      CancelToken? cancelToken,
      Options? options}) async {
    ResponseBean? response = await request(HttpMethod.GET, '/api/v1/tokens',
        data: data, cancelToken: cancelToken, options: options);
    if (response != null && response.errorCode == 0) {
      return UserBean.fromJson(response.data);
    }
  }

  static Future<List<TeamBean>?> listTeams(
      {Map<String, dynamic>? data,
      CancelToken? cancelToken,
      Options? options}) async {
    ResponseBean? response = await request(HttpMethod.GET, '/api/v1/teams',
        data: data, cancelToken: cancelToken, options: options);
    if (response != null && response.errorCode == 0) {
      List items = response.data["teams"];
      return items.map((i) => TeamBean.fromJson(i)).toList();
    }
  }

  static Future<List<NodeBean>?> listTeamNodes(String teamID,
      {Map<String, dynamic>? data,
      CancelToken? cancelToken,
      Options? options}) async {
    ResponseBean? response = await request(
        HttpMethod.GET, '/api/v1/teams/' + teamID + '/nodes',
        data: data, cancelToken: cancelToken, options: options);
    if (response != null && response.errorCode == 0) {
      List items = response.data["nodes"];
      return items.map((i) => NodeBean.fromJson(i)).toList();
    }
  }

  static Future<NodeBean?> createTeamNode(String teamID,
      {Map<String, dynamic>? data,
      CancelToken? cancelToken,
      Options? options}) async {
    ResponseBean? response = await request(
        HttpMethod.POST, '/api/v1/teams/' + teamID + '/nodes',
        data: data, cancelToken: cancelToken, options: options);
    if (response != null && response.errorCode == 0) {
      return NodeBean.fromJson(response.data);
    }
  }

  static Future<NodeBean?> patchNode(String nodeID,
      {Map<String, dynamic>? data,
      CancelToken? cancelToken,
      Options? options}) async {
    ResponseBean? response = await request(
        HttpMethod.PATCH, '/api/v1/nodes/' + nodeID,
        data: data, cancelToken: cancelToken, options: options);
    if (response != null && response.errorCode == 0) {
      return NodeBean.fromJson(response.data);
    }
  }

  static Future<List<BlockBean>?> listNodeBlocks(String nodeID,
      {Map<String, dynamic>? data,
      CancelToken? cancelToken,
      Options? options}) async {
    ResponseBean? response = await request(
        HttpMethod.GET, '/api/v1/nodes/' + nodeID + '/blocks',
        data: data, cancelToken: cancelToken, options: options);
    if (response != null && response.errorCode == 0) {
      List items = response.data["blocks"];
      return items.map((i) => BlockBean.fromJson(i)).toList();
    }
  }

  static Future<BlockBean?> createNodeBlock(String nodeID,
      {Map<String, dynamic>? data,
      CancelToken? cancelToken,
      Options? options}) async {
    ResponseBean? response = await request(
        HttpMethod.POST, '/api/v1/nodes/' + nodeID + '/blocks',
        data: data, cancelToken: cancelToken, options: options);
    if (response != null && response.errorCode == 0) {
      return BlockBean.fromJson(response.data);
    }
  }

  static Future<BlockBean?> patchBlock(String blockID,
      {Map<String, dynamic>? data,
      CancelToken? cancelToken,
      Options? options}) async {
    ResponseBean? response = await request(
        HttpMethod.PATCH, '/api/v1/blocks/' + blockID,
        data: data, cancelToken: cancelToken, options: options);
    if (response != null && response.errorCode == 0) {
      return BlockBean.fromJson(response.data);
    }
  }

  static Future<BlockBean?> deleteBlock(String blockID,
      {Map<String, dynamic>? data,
      CancelToken? cancelToken,
      Options? options}) async {
    ResponseBean? response = await request(
        HttpMethod.DELETE, '/api/v1/blocks/' + blockID,
        data: data, cancelToken: cancelToken, options: options);
    if (response != null && response.errorCode == 0) {
      return BlockBean.fromJson(response.data);
    }
  }

  static Future<TableBean?> getNodeTable(String nodeID,
      {Map<String, dynamic>? data,
      CancelToken? cancelToken,
      Options? options}) async {
    ResponseBean? response = await request(
        HttpMethod.GET, '/api/v1/nodes/' + nodeID + '/table',
        data: data, cancelToken: cancelToken, options: options);
    if (response != null && response.errorCode == 0) {
      return TableBean.fromJson(response.data);
    }
  }

  static Future<ColumnBean?> createColumn(String tableID,
      {Map<String, dynamic>? data,
      CancelToken? cancelToken,
      Options? options}) async {
    ResponseBean? response = await request(
        HttpMethod.POST, '/api/v1/tables/' + tableID + '/columns',
        data: data, cancelToken: cancelToken, options: options);
    if (response != null && response.errorCode == 0) {
      return ColumnBean.fromJson(response.data);
    }
  }

  static Future<Map<String, String>?> createRow(String tableID,
      {Map<String, dynamic>? data,
      CancelToken? cancelToken,
      Options? options}) async {
    ResponseBean? response = await request(
        HttpMethod.POST, '/api/v1/tables/' + tableID + '/rows',
        data: data, cancelToken: cancelToken, options: options);
    if (response != null && response.errorCode == 0) {
      return Map<String, String>.from(response.data);
    }
  }

  static Future<Map<String, String>?> patchRow(String tableID, String rowID,
      {Map<String, dynamic>? data,
      CancelToken? cancelToken,
      Options? options}) async {
    ResponseBean? response = await request(
        HttpMethod.PATCH, '/api/v1/tables/' + tableID + '/rows/' + rowID,
        data: data, cancelToken: cancelToken, options: options);
    if (response != null && response.errorCode == 0) {
      return Map<String, String>.from(response.data);
    }
  }

  static Future<Map<String, String>?> deleteRow(String tableID, String rowID,
      {Map<String, dynamic>? data,
      CancelToken? cancelToken,
      Options? options}) async {
    ResponseBean? response = await request(
        HttpMethod.DELETE, '/api/v1/tables/' + tableID + '/rows/' + rowID,
        data: data, cancelToken: cancelToken, options: options);
    if (response != null && response.errorCode == 0) {
      return Map<String, String>.from(response.data);
    }
  }

  static Future<List<Map<String, String>>?> getTableRows(String tableID,
      {Map<String, dynamic>? data,
      CancelToken? cancelToken,
      Options? options}) async {
    ResponseBean? response = await request(
        HttpMethod.GET, '/api/v1/tables/' + tableID + '/rows',
        data: data, cancelToken: cancelToken, options: options);
    if (response != null && response.errorCode == 0) {
      debugPrint(response.data.toString());
      List items = response.data["rows"];
      return items.map((item) {
        item = item as Map<String, dynamic>;
        Map<String, String> row = {};
        item.forEach((key, value) {
          row[key] = value as String;
        });
        return row;
      }).toList();
    }
  }
}
