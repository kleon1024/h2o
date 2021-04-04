import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:h2o/components/nodes/basic_node.dart';
import 'package:h2o/pages/channel/channel_page.dart';

class TextChannelNode extends StatelessWidget {
  final name;
  final indentLevel;

  const TextChannelNode({this.name = "", this.indentLevel = 0});

  @override
  Widget build(BuildContext context) {
    return BasicNode(
      expanded: true,
      indentLevel: this.indentLevel,
      name: this.name,
      icon: CupertinoIcons.number,
      onTapNode: () {
        Navigator.of(context).push(
          CupertinoPageRoute(builder: (ctx) {
            return ChannelPage();
          }),
        );
      },
      onTapPlus: () {},
    );
  }
}
