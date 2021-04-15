import 'package:flutter/cupertino.dart';
import 'package:h2o/dao/node.dart';
import 'package:h2o/dao/table.dart';

class IconMap {
  static Map<NodeType, IconData> nodeType = {
    NodeType.directory: CupertinoIcons.collections,
    NodeType.channel: CupertinoIcons.number,
    NodeType.document: CupertinoIcons.doc_text,
    NodeType.table: CupertinoIcons.cube,
  };
  static Map<ColumnType, IconData> columnType = {
    ColumnType.string: CupertinoIcons.textformat_abc,
    ColumnType.integer: CupertinoIcons.textformat_123,
    ColumnType.date: CupertinoIcons.calendar,
  };
}
