import 'package:flutter/cupertino.dart';
import 'package:h2o/dao/node.dart';

class IconMap {
  static Map<NodeType, IconData> nodeType = {
    NodeType.directory: CupertinoIcons.collections,
    NodeType.channel: CupertinoIcons.number,
    NodeType.document: CupertinoIcons.doc_text,
    NodeType.table: CupertinoIcons.cube,
  };
}
