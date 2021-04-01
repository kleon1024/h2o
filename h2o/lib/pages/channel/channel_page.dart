import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:h2o/components/blocks/block.dart';
import 'package:h2o/components/scroll/bouncing_scroll_view.dart';
import 'package:h2o/global/enum.dart';

class ChannelPage extends StatelessWidget {
  final blocks = [
    BlockType.h1,
    BlockType.text,
    BlockType.bulleted_list,
    BlockType.bulleted_list,
    BlockType.bulleted_list,
    BlockType.numbered_list,
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(tr("app.title")),
        actions: [
          IconButton(onPressed: () {}, icon: Icon(Icons.search)),
          IconButton(onPressed: () {}, icon: Icon(Icons.group)),
        ],
      ),
      body: BouncingScrollView(
        scrollBar: true,
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
      ),
    );
  }
}
