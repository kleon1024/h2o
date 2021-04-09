import 'package:dio/dio.dart';
import 'package:enum_to_string/enum_to_string.dart';
import 'package:h2o/bean/response.dart';
import 'package:h2o/bean/team.dart';
import 'package:h2o/bean/user.dart';
import 'package:h2o/global/enum.dart';

class Api {
  static final _client = Dio();

  static initialize() {
    _client.options.baseUrl = "http://127.0.0.1:8080";
    _client.options.connectTimeout = 10 * 1000; // 10s
    _client.options.receiveTimeout = 15 * 1000; // 15s
    _client.interceptors.add(LogInterceptor(
      responseBody: true,
      requestHeader: true,
      responseHeader: false,
      request: true,
    ));
  }

  Dio get client => _client;

  static String getBaseUrl() {
    return _client.options.baseUrl;
  }

  static Future<ResponseBean?> request(
    HttpMethod method,
    String url, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    CancelToken? cancelToken,
    Options? options,
  }) async {
    if (options != null) {
      options.method = EnumToString.convertToString(method);
    } else {
      options = Options(method: EnumToString.convertToString(method));
    }

    var response;
    try {
      response = await _client.request(url, data: data, options: options);
    } catch (e) {}
    if (response != null) {
      ResponseBean resp = ResponseBean.fromJson(response.data);
      return resp;
    }
  }

  // APIs
  static Future<UserBean?> createUser(
      {dynamic data, CancelToken? cancelToken, Options? options}) async {
    ResponseBean? response = await request(HttpMethod.POST, '/api/v1/users',
        data: data, cancelToken: cancelToken, options: options);
    if (response != null && response.errorCode == 0) {
      return UserBean.fromJson(response.data);
    }
  }

  static Future<UserBean?> refreshToken(
      {dynamic data, CancelToken? cancelToken, Options? options}) async {
    ResponseBean? response = await request(HttpMethod.GET, '/api/v1/tokens',
        data: data, cancelToken: cancelToken, options: options);
    if (response != null && response.errorCode == 0) {
      return UserBean.fromJson(response.data);
    }
  }

  static Future<List<TeamBean>?> listTeams(
      {dynamic data, CancelToken? cancelToken, Options? options}) async {
    ResponseBean? response = await request(HttpMethod.GET, '/api/v1/teams',
        data: data, cancelToken: cancelToken, options: options);
    if (response != null && response.errorCode == 0) {
      List items = response.data["teams"];
      return items.map((i) => TeamBean.fromJson(i)).toList();
    }
  }
}
