import 'package:flutter/material.dart';
import 'package:h2o/components/blocks/block.dart';
import 'package:h2o/global/enum.dart';

class ChannelPage extends StatelessWidget {
  final blocks = [
    BlockType.h1,
    BlockType.text,
    BlockType.bulleted_list,
    BlockType.numbered_list,
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("TODO"),
          actions: [
            IconButton(onPressed: () {}, icon: Icon(Icons.search)),
            IconButton(onPressed: () {}, icon: Icon(Icons.group)),
          ],
        ),
        body: CustomScrollView(
          physics:
              BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
          slivers: [
            SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
                return Container(
                    padding: EdgeInsets.symmetric(
                      vertical: 10,
                      horizontal: 20,
                    ),
                    child: Block(type: blocks[index]));
              }, childCount: blocks.length),
            )
          ],
        ));
  }
}
