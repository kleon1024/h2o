import 'package:flutter/cupertino.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

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
    var dataBasePath = await getDatabasesPath();
    String path = join(dataBasePath, "h2o.db");
    return await openDatabase(path, version: 1, onOpen: (db) {},
        onCreate: (Database db, int version) async {
      debugPrint("Current db version: $version");
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
          "updated_at INTEGER");
    });
  }
}
