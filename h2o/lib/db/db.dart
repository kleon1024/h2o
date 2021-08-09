import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:h2o/bean/node.dart';
import 'package:h2o/utils/platform.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common/sqlite_api.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class DBProvider {
  DBProvider._();

  static final DBProvider db = DBProvider._();

  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await initDB();
    return _database!;
  }

  initDB() async {
    String path = "h2o.db";
    if (PlatformInfo().isAppOS()) {
      debugPrint("isAppOS");
      var dataBasePath = await getDatabasesPath();
      path = p.join(dataBasePath, path);
    }

    if (Platform.isWindows || Platform.isLinux) {
      // Initialize FFI
      sqfliteFfiInit();
      // Change the default factory
      databaseFactory = databaseFactoryFfi;
    }

    return await databaseFactory.openDatabase(path,
        options: OpenDatabaseOptions(
            version: 1,
            onOpen: (db) {},
            onCreate: (Database db, int version) async {
              debugPrint("Current db version: $version");
              await db.execute("CREATE TABLE team ("
                  "id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,"
                  "uuid TEXT,"
                  "name TEXT"
                  ")");
              await db.execute("CREATE TABLE node ("
                  "id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,"
                  "uuid TEXT,"
                  "type TEXT,"
                  "name TEXT,"
                  "indent INTEGER DEFAULT 0,"
                  "previous_id TEXT,"
                  "created_at INTEGER,"
                  "updated_at INTEGER"
                  ")");
              await db.execute("CREATE TABLE block ("
                  "id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,"
                  "uuid TEXT,"
                  "type TEXT,"
                  "text TEXT,"
                  "revision INTEGER,"
                  "author_id TEXT,"
                  "previous_id TEXT,"
                  "created_at INTEGER,"
                  "updated_at INTEGER"
                  ")");
            },
            onUpgrade: (Database db, int oldVersion, int newVersion) async {
              debugPrint("Newer version: $newVersion");
              debugPrint("Older version: $oldVersion");
            }));
  }

  Future<List<NodeBean>> getNodes() async {
    final db = await database;
    var list = await db.query("node");
    return list.map((e) => NodeBean.fromJson(e)).toList();
  }

  Future insertNode(NodeBean bean) async {
    final db = await database;
    await db.insert("node", bean.toJson());
  }
}
