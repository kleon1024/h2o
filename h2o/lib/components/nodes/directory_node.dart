import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:h2o/bean/node.dart';
import 'package:h2o/components/nodes/basic_node.dart';
import 'package:h2o/dao/node.dart';
import 'package:h2o/global/icons.dart';

class DirectoryNode extends StatelessWidget {
  final NodeBean nodeBean;

  const DirectoryNode(this.nodeBean);

  @override
  Widget build(BuildContext context) {
    return BasicNode(
      expanded: false,
      indentLevel: 0,
      name: nodeBean.name,
      icon: IconMap.nodeType[NodeType.directory],
      onTapNode: () {},
      onTapPlus: () {},
    );
  }
}
