import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:h2o/components/nodes/node.dart';
import 'package:h2o/components/scroll/bouncing_scroll_view.dart';
import 'package:h2o/global/enum.dart';

class TeamTree extends StatelessWidget {
  final nodes = [
    NodeType.Directory,
    NodeType.TextChannel,
    NodeType.Document,
    NodeType.Table,
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      margin: EdgeInsets.symmetric(vertical: 18, horizontal: 8),
      decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.all(Radius.circular(8))),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.transparent,
          title: Text("Yeah My Team"),
          titleSpacing: 0.0,
        ),
        body: BouncingScrollView(
          slivers: [
            SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
              return Node(type: nodes[index]);
            }, childCount: nodes.length))
          ],
        ),
      ),
    );
  }
}
