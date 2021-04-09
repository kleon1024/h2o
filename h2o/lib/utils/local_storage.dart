import 'dart:convert';

import 'package:enum_to_string/enum_to_string.dart';
import 'package:h2o/global/enum.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalStorage {
  static Future setString(StorageKey key, String value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(EnumToString.convertToString(key), value);
  }

  static Future getString(StorageKey key) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(EnumToString.convertToString(key));
  }

  static Future setJson(StorageKey key, Map<String, dynamic> json) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(EnumToString.convertToString(key), jsonEncode(json));
  }

  static Future getJson(StorageKey key) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? value = prefs.getString(EnumToString.convertToString(key));
    if (value != null) {
      return jsonDecode(value);
    }
  }
}
