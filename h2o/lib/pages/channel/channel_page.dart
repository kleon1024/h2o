import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:h2o/bean/block.dart';
import 'package:h2o/components/blocks/block.dart';
import 'package:h2o/components/scroll/bouncing_scroll_view.dart';
import 'package:h2o/dao/block.dart';
import 'package:h2o/dao/node.dart';
import 'package:h2o/model/channel/channel_page.dart';
import 'package:provider/provider.dart';

class ChannelPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final channelPageModel = Provider.of<ChannelPageModel>(context);
    final blockDao = Provider.of<BlockDao>(context);

    List<BlockBean> blocks = [];
    if (blockDao.blockMap.containsKey(channelPageModel.node.uuid)) {
      blocks = blockDao.blockMap[channelPageModel.node.uuid]!;
    }

    OutlineInputBorder inputBorder = OutlineInputBorder(
      borderRadius: const BorderRadius.all(
        const Radius.circular(10),
      ),
      borderSide: BorderSide(color: Colors.transparent),
    );

    return Scaffold(
      backgroundColor: Theme.of(context).cardColor,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(36),
        child: AppBar(
          title: Text(channelPageModel.node.name),
          actions: [
            IconButton(onPressed: () {}, icon: Icon(Icons.group, size: 18)),
          ],
        ),
      ),
      body: Column(children: [
        Expanded(
          child: BouncingScrollView(
            scrollBar: true,
            reverse: true,
            slivers: [
              SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  bool showCreator = true;
                  if (index < blocks.length - 1) {
                    if (blocks[index + 1].authorId == blocks[index].authorId) {
                      showCreator = false;
                    }
                  }

                  return Container(
                      padding: EdgeInsets.symmetric(
                        vertical: 2,
                        horizontal: 20,
                      ),
                      child: Block(
                        blocks[index],
                        NodeType.channel,
                        index,
                        showCreator: showCreator,
                      ));
                }, childCount: blocks.length),
              ),
            ],
          ),
        ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 20),
          height: 80,
          child: Row(
            children: [
              // Container(
              //   width: 42,
              // ),
              Expanded(
                child: TextField(
                  focusNode: channelPageModel.focusNode,
                  style: Theme.of(context).textTheme.bodyText1,
                  controller: channelPageModel.controller,
                  textInputAction: TextInputAction.send,
                  keyboardType: TextInputType.text,
                  onSubmitted: channelPageModel.onTapCreateBlock,
                  decoration: InputDecoration(
                    isDense: true,
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                    fillColor: Theme.of(context).canvasColor,
                    filled: true,
                    enabledBorder: inputBorder,
                    focusedBorder: inputBorder,
                  ),
                ),
              ),
            ],
          ),
        )
      ]),
    );
  }
}
