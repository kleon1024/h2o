import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:h2o/components/nodes/basic_node.dart';
import 'package:h2o/pages/table/table_page.dart';

class TableNode extends StatelessWidget {
  final name;
  final indentLevel;

  const TableNode({this.name = "", this.indentLevel = 0});

  @override
  Widget build(BuildContext context) {
    return BasicNode(
      expanded: true,
      indentLevel: this.indentLevel,
      name: this.name,
      icon: CupertinoIcons.table,
      onTapNode: () {
        Navigator.of(context).push(
          CupertinoPageRoute(builder: (ctx) {
            return TablePage();
          }),
        );
      },
      onTapPlus: () {},
    );
  }
}
