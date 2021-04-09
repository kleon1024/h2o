import 'package:enum_to_string/enum_to_string.dart';
import 'package:flutter/cupertino.dart';
import 'package:h2o/bean/node.dart';
import 'package:h2o/components/nodes/directory_node.dart';
import 'package:h2o/components/nodes/document_node.dart';
import 'package:h2o/components/nodes/table_node.dart';
import 'package:h2o/components/nodes/text_channel_node.dart';
import 'package:h2o/global/enum.dart';

class Node extends StatelessWidget {
  final NodeBean node;

  const Node(this.node);

  @override
  Widget build(BuildContext context) {
    NodeType? type = EnumToString.fromString(NodeType.values, this.node.type);
    if (type == null) {
      return Container();
    }

    Widget node;
    switch (type) {
      case NodeType.Directory:
        node = DirectoryNode(name: "develop", indentLevel: 0);
        break;
      case NodeType.TextChannel:
        node = TextChannelNode(name: "程序开发", indentLevel: 1);
        break;
      case NodeType.Document:
        node = DocumentNode(name: "开发文档", indentLevel: 2);
        break;
      case NodeType.Table:
        node = TableNode(name: "CPU性能优化", indentLevel: 3);
        break;
      default:
        node = DirectoryNode(name: "unknown", indentLevel: 0);
        break;
    }
    return node;
  }
}
