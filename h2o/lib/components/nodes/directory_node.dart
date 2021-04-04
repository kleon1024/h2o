import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:h2o/components/nodes/basic_node.dart';

class DirectoryNode extends StatelessWidget {
  final name;
  final indentLevel;

  const DirectoryNode({this.name = "", this.indentLevel = 0});

  @override
  Widget build(BuildContext context) {
    return BasicNode(
      expanded: true,
      indentLevel: this.indentLevel,
      name: this.name,
      icon: CupertinoIcons.collections,
      onTapNode: () {},
      onTapPlus: () {},
    );
  }
}
