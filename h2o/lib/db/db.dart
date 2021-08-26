import 'dart:async';
import 'dart:io';

import 'package:enum_to_string/enum_to_string.dart';
import 'package:flutter/cupertino.dart';
import 'package:h2o/bean/block.dart';
import 'package:h2o/bean/column.dart';
import 'package:h2o/bean/node.dart';
import 'package:h2o/bean/row.dart';
import 'package:h2o/bean/select.dart';
import 'package:h2o/dao/table.dart';
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
    if (PlatformInfo().isWeb()) {
      debugPrint("Web is currently not supported");
    } else if (PlatformInfo().isAppOS()) {
      debugPrint("isAppOS");
      var dataBasePath = await getDatabasesPath();
      path = p.join(dataBasePath, path);
    } else if (Platform.isWindows || Platform.isLinux) {
      debugPrint("isWindows isLinux");
      // Initialize FFI
      sqfliteFfiInit();
      // Change the default factory
      databaseFactory = databaseFactoryFfi;
    }

    return await databaseFactory.openDatabase(path,
        options: OpenDatabaseOptions(
            version: 3,
            onOpen: (db) {},
            onCreate: (Database db, int version) async {
              debugPrint("Current db version: $version");
              await db.execute("CREATE TABLE teams ("
                  "id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,"
                  "uuid TEXT,"
                  "name TEXT"
                  ")");
              await db.execute("CREATE TABLE nodes ("
                  "id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,"
                  "uuid TEXT,"
                  "type TEXT,"
                  "name TEXT,"
                  "draft TEXT,"
                  "indent INTEGER DEFAULT 0,"
                  "parent_id TEXT,"
                  "previous_id TEXT,"
                  "team_id TEXT,"
                  "created_at INTEGER,"
                  "updated_at INTEGER"
                  ")");
              await db.execute("CREATE TABLE blocks ("
                  "id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,"
                  "uuid TEXT,"
                  "type TEXT,"
                  "text TEXT,"
                  "revision INTEGER,"
                  "author_id TEXT,"
                  "previous_id TEXT,"
                  "node_id TEXT,"
                  "properties TEXT,"
                  "created_at INTEGER,"
                  "updated_at INTEGER"
                  ")");
              await db.execute("CREATE TABLE columns("
                  "id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,"
                  "uuid TEXT,"
                  "name TEXT,"
                  "type TEXT,"
                  "table_id TEXT,"
                  "default_value TEXT,"
                  "created_at INTEGER,"
                  "updated_at INTEGER"
                  ")");
              await db.execute("CREATE TABLE IF NOT EXISTS channel_drafts("
                  "id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,"
                  "uuid TEXT,"
                  "draft TEXT"
                  ")");
              await db.execute("CREATE TABLE IF NOT EXISTS selects("
                  "id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,"
                  "uuid TEXT,"
                  "text TEXT,"
                  "column_id TEXT,"
                  "color INT"
                  ")");
            },
            onUpgrade: (Database db, int oldVersion, int newVersion) async {
              if (oldVersion == 1) {
                await db.execute("ALTER TABLE nodes ADD draft TEXT DEFAULT ''");
              }
              if (oldVersion == 2) {
                await db.execute("CREATE TABLE IF NOT EXISTS selects("
                    "id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,"
                    "uuid TEXT,"
                    "text TEXT,"
                    "column_id TEXT,"
                    "color INT"
                    ")");
              }
              debugPrint("Newer version: $newVersion");
              debugPrint("Older version: $oldVersion");
            }));
  }

  Future updateChannelDraft(String nodeId, String draft) async {
    final db = await database;
    await db.update("nodes", {"draft": draft},
        where: "uuid = ?", whereArgs: [nodeId]);
  }

  Future<List<NodeBean>> getNodes(String teamId, String parentId) async {
    final db = await database;
    var list = await db.query("nodes",
        where: "team_id = ? AND parent_id = ?", whereArgs: [teamId, parentId]);
    return list.map((e) => NodeBean.fromJson(e)).toList();
  }

  Future<List<NodeBean>> getPlainNodes(String teamId, String type) async {
    final db = await database;
    var list = await db.query("nodes",
        where: "team_id = ? AND type = ?",
        whereArgs: [teamId, type],
        orderBy: "updated_at DESC");
    return list.map((e) => NodeBean.fromJson(e)).toList();
  }

  Future insertNode(NodeBean bean) async {
    final db = await database;
    var n = await findPreviousNode(bean.parentId, bean.previousId);
    if (n != null) {
      n.previousId = bean.uuid;
      await updateNode(n);
      debugPrint("update node:" + n.previousId + ":" + n.uuid);
    }
    await db.insert("nodes", bean.toJson());
    debugPrint("insert node:" + bean.previousId + ":" + bean.uuid);
  }

  Future<NodeBean?> findNode(String uuid) async {
    final db = await database;
    var nodes = await db.query("nodes", where: "uuid = ?", whereArgs: [uuid]);
    if (nodes.length > 1) {
      debugPrint("warning: find multiple nodes with same uuid=" +
          uuid +
          " which is unexpected");
    } else if (nodes.length == 0) {
      debugPrint("warning: cannot find any node with uuid=" + uuid);
      return null;
    }
    return NodeBean.fromJson(nodes[0]);
  }

  Future<NodeBean?> findPreviousNode(String parentId, String previousId) async {
    final db = await database;
    var nodes = await db.query("nodes",
        where: "previous_id = ? AND parent_id = ?",
        whereArgs: [previousId, parentId]);
    if (nodes.length > 1) {
      debugPrint("warning: find multiple nodes with same previous_id=" +
          previousId +
          " AND parent_id=" +
          parentId +
          " which is unexpected");
    } else if (nodes.length == 0) {
      debugPrint("warning: cannot find any node with previous_id=" +
          previousId +
          " AND parent_id=" +
          parentId);
      return null;
    }
    return NodeBean.fromJson(nodes[0]);
  }

  Future<BlockBean?> findPreviousBlock(String uuid, String nodeId) async {
    final db = await database;
    var blocks = await db.query("blocks",
        where: "previous_id = ? AND node_id = ?", whereArgs: [uuid, nodeId]);
    if (blocks.length > 1) {
      debugPrint("warning: find multiple blocks with same previous_id=" +
          uuid +
          " which is unexpected");
    } else if (blocks.length == 0) {
      debugPrint("warning: cannot find any node with previous_id=" + uuid);
      return null;
    }
    return BlockBean.fromJson(blocks[0]);
  }

  Future updateBlock(BlockBean bean) async {
    final db = await database;
    await db.update("blocks", bean.toJson(),
        where: "uuid = ?", whereArgs: [bean.uuid]);
  }

  Future updateNode(NodeBean bean) async {
    final db = await database;
    await db.update("nodes", bean.toJson(),
        where: "uuid = ?", whereArgs: [bean.uuid]);
  }

  Future deleteNode(NodeBean bean) async {
    final db = await database;
    var n = await findPreviousNode(bean.parentId, bean.uuid);
    if (n != null) {
      n.previousId = bean.previousId;
      await updateNode(n);
      debugPrint("update node:" + n.previousId + ":" + n.previousId);
    }
    await db.delete("nodes", where: "uuid = ?", whereArgs: [bean.uuid]);
  }

  Future deleteAllNodes() async {
    final db = await database;
    await db.delete("nodes");
  }

  Future<List<BlockBean>> getBlocks(String uuid,
      {limit = 20, offset = 0}) async {
    final db = await database;
    debugPrint("get blocks node_id=" + uuid);
    var list = await db.query("blocks",
        orderBy: "created_at DESC",
        where: "node_id = ?",
        whereArgs: [uuid],
        limit: limit,
        offset: offset);
    return list.map((e) => BlockBean.fromJson(e)).toList();
  }

  Future insertBlock(BlockBean bean) async {
    final db = await database;
    await db.insert("blocks", bean.toJson());
    debugPrint("insert blocks node_id=" + bean.nodeId + " id=" + bean.uuid);
  }

  Future deleteBlock(BlockBean bean) async {
    final db = await database;
    await db.delete("blocks", where: "uuid = ?", whereArgs: [bean.uuid]);
  }

  Future insertDocumentBlock(BlockBean bean) async {
    final db = await database;

    var n = await findPreviousBlock(bean.previousId, bean.nodeId);
    if (n != null) {
      n.previousId = bean.uuid;
      await updateBlock(n);
      debugPrint("update block before insert:" + n.previousId + ":" + n.uuid);
    }

    await db.insert("blocks", bean.toJson());
    debugPrint("insert block:" + bean.previousId + ":" + bean.uuid);
  }

  Future deleteDocumentBlock(BlockBean bean) async {
    final db = await database;
    var n = await findPreviousBlock(bean.uuid, bean.nodeId);
    if (n != null) {
      n.previousId = bean.previousId;
      await updateBlock(n);
      debugPrint(
          "update block before delete:" + n.previousId + ":" + n.previousId);
    }
    await db.delete("blocks", where: "uuid = ?", whereArgs: [bean.uuid]);
    debugPrint("delete block:" + bean.previousId + ":" + bean.uuid);
  }

  Future insertTable(NodeBean bean) async {
    final db = await database;

    var sql = "CREATE TABLE \"" +
        bean.uuid +
        "\" (id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,"
            "uuid TEXT,"
            "created_by TEXT,"
            "updated_by TEXT,"
            "created_at INT,"
            "updated_at INT"
            ")";
    debugPrint(sql);
    await db.execute(sql);
  }

  Future insertColumn(ColumnBean bean) async {
    final db = await database;
    await db.insert("columns", bean.toJson());

    String type = "TEXT";
    switch (EnumToString.fromString(ColumnType.values, bean.type)) {
      case ColumnType.string:
        type = "TEXT";
        break;
      case ColumnType.integer:
        type = "INT";
        break;
      case ColumnType.date:
        type = "INT";
        break;
      case ColumnType.number:
        type = "DOUBLE";
        break;
      default:
        type = "TEXT";
    }

    var sql = "ALTER TABLE \"" +
        bean.tableId +
        "\" ADD COLUMN \"" +
        bean.uuid +
        "\" " +
        type;

    sql += " DEFAULT '" + bean.defaultValue + "'";

    debugPrint(sql);
    await db.execute(sql);
  }

  Future<List<ColumnBean>> getColumns(String uuid) async {
    final db = await database;
    var list =
        await db.query("columns", where: "table_id = ?", whereArgs: [uuid]);
    List<ColumnBean> columns = list.map((e) => ColumnBean.fromJson(e)).toList();
    for (var c in columns) {
      if (c.type == EnumToString.convertToString(ColumnType.select) ||
          c.type == EnumToString.convertToString(ColumnType.multi_select)) {
        c.selects = await getSelects(c.uuid);
      }
    }
    debugPrint("get cols table_id=" + uuid + " columns=" + columns.toString());
    return columns;
  }

  Future insertSelect(SelectBean bean) async {
    final db = await database;
    await db.insert("selects", bean.toJson());
    debugPrint("insert select column_id=" + bean.columnId + " id=" + bean.uuid);
  }

  Future deleteSelect(SelectBean bean) async {
    final db = await database;
    await db.delete("selects", where: "uuid = ?", whereArgs: [bean.uuid]);
    debugPrint("delete select column_id=" + bean.columnId + " id=" + bean.uuid);
  }

  // Future insertRowSelect(String rowId, String selectId) async {
  //   final db = await database;
  //   await db.insert("row_selects", {"row_id": rowId, "select_id": selectId});
  //   debugPrint("insert row select row_id=" + rowId + " select_id=" + selectId);
  // }
  //
  // Future deleteRowSelect(String rowId, String selectId) async {
  //   final db = await database;
  //   await db.delete("row_selects",
  //       where: "row_id = ? AND select_id = ?", whereArgs: [rowId, selectId]);
  //   debugPrint("delete row select row_id=" + rowId + " select_id=" + selectId);
  // }

  Future<List<SelectBean>> getSelects(String columnId) async {
    final db = await database;
    var list = await db
        .query("selects", where: "column_id = ?", whereArgs: [columnId]);
    return list.map((e) => SelectBean.fromJson(e)).toList();
  }

  Future<List<RowBean>> getRows(String uuid, List<String> columns) async {
    final db = await database;
    List<String> colSqls = ["\"uuid\"", "\"created_at\", \"updated_at\""];
    columns.forEach((c) {
      colSqls.add("\"" + c + "\"");
    });

    var list = await db.query("\"" + uuid + "\"", columns: colSqls);
    return list
        .map((e) => () {
              List<Object> row = [];
              columns.forEach((c) {
                row.add(e[c]!);
              });
              return RowBean(
                  uuid: e["uuid"]! as String,
                  createdAt: e["created_at"] as int,
                  updatedAt: e["updated_at"] as int,
                  values: row);
            }())
        .toList();
  }

  Future insertRows(
      String tableId, List<String> columns, List<RowBean> rows) async {
    final db = await database;
    final batch = db.batch();

    rows.forEach((row) {
      Map<String, Object> record = {};
      for (int i = 0; i < columns.length; i++) {
        record["\"" + columns[i] + "\""] = row.values[i];
      }
      record["uuid"] = row.uuid;
      record["created_at"] = row.createdAt;
      record["updated_at"] = row.updatedAt;
      batch.insert("\"" + tableId + "\"", record);
    });

    await batch.commit();
  }

  Future updateRows(
      String tableId, List<String> columns, List<RowBean> rows) async {
    final db = await database;
    final batch = db.batch();

    debugPrint("table: " + tableId);
    debugPrint("columns: " + columns.toString());
    debugPrint(rows[0].uuid + " " + rows[0].values.toString());

    rows.forEach((row) {
      Map<String, Object> record = {};
      for (int i = 0; i < columns.length; i++) {
        record["\"" + columns[i] + "\""] = row.values[i];
      }
      record["created_at"] = row.createdAt;
      record["updated_at"] = row.updatedAt;
      batch.update("\"" + tableId + "\"", record,
          where: "uuid = ?", whereArgs: [row.uuid]);
    });

    await batch.commit();
  }
}
