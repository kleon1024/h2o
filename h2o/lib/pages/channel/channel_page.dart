import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:h2o/bean/block.dart';
import 'package:h2o/components/blocks/block.dart';
import 'package:h2o/components/scroll/bouncing_scroll_view.dart';
import 'package:h2o/dao/block.dart';
import 'package:h2o/model/channel/channel_page.dart';
import 'package:provider/provider.dart';

class ChannelPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final channelPageModel = Provider.of<ChannelPageModel>(context);
    final blockDao = Provider.of<BlockDao>(context);

    List<BlockBean> blocks = [];
    if (blockDao.blockMap.containsKey(channelPageModel.node.id)) {
      blocks = blockDao.blockMap[channelPageModel.node.id]!.reversed.toList();
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
          title: Text(tr("app.title")),
          actions: [
            IconButton(onPressed: () {}, icon: Icon(Icons.search)),
            IconButton(onPressed: () {}, icon: Icon(Icons.group)),
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
                  return Container(
                      padding: EdgeInsets.symmetric(
                        vertical: 5,
                        horizontal: 20,
                      ),
                      child: Block(
                        blocks[index],
                        showCreator: true,
                      ));
                }, childCount: blocks.length),
              ),
            ],
          ),
        ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 10),
          height: 80,
          child: Row(
            children: [
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
