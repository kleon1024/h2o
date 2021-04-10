import 'package:enum_to_string/enum_to_string.dart';
import 'package:flutter/cupertino.dart';
import 'package:h2o/bean/node.dart';
import 'package:h2o/components/nodes/channel_node.dart';
import 'package:h2o/components/nodes/directory_node.dart';
import 'package:h2o/components/nodes/document_node.dart';
import 'package:h2o/components/nodes/table_node.dart';
import 'package:h2o/dao/node.dart';

class Node extends StatelessWidget {
  final NodeBean nodeBean;

  const Node(this.nodeBean);

  @override
  Widget build(BuildContext context) {
    NodeType? type =
        EnumToString.fromString(NodeType.values, this.nodeBean.type);
    if (type == null) {
      return Container();
    }

    Widget node;
    switch (type) {
      case NodeType.directory:
        node = DirectoryNode(nodeBean);
        break;
      case NodeType.channel:
        node = ChannelNode(nodeBean);
        break;
      case NodeType.document:
        node = DocumentNode(nodeBean);
        break;
      case NodeType.table:
        node = TableNode(nodeBean);
        break;
      default:
        node = DirectoryNode(nodeBean);
        break;
    }
    return node;
  }
}
