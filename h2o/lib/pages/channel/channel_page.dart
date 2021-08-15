import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:h2o/bean/block.dart';
import 'package:h2o/components/blocks/block.dart';
import 'package:h2o/components/buttons/tooltip_button.dart';
import 'package:h2o/components/scroll/bouncing_scroll_view.dart';
import 'package:h2o/dao/block.dart';
import 'package:h2o/dao/node.dart';
import 'package:h2o/model/channel/channel_page.dart';
import 'package:provider/provider.dart';
import 'package:simple_tooltip/simple_tooltip.dart';

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

    Widget leading = IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        Navigator.of(context).pop();
      },
    );

    if (channelPageModel.selecting) {
      leading = TextButton(
        child: Text(tr("channel.block.selection.cancel"),
            style: Theme.of(context).textTheme.caption,
            overflow: TextOverflow.ellipsis),
        onPressed: () {
          channelPageModel.onTapSelectionCancel();
        },
      );
    }

    Widget widget = Container(
      padding: EdgeInsets.symmetric(horizontal: 20),
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
    );

    if (channelPageModel.selecting) {
      widget = Container(
        padding: EdgeInsets.symmetric(horizontal: 20),
        height: 60,
        decoration: new BoxDecoration(
          color: Theme.of(context).cardColor,
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 25.0, // soften the shadow
              spreadRadius: 5.0, //extend the shadow
              offset: Offset(
                0, // Move to right 10  horizontally
                0, // Move to bottom 10 Vertically
              ),
            )
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [TooltipButton(icon: Icons.forward_outlined)],
        ),
      );
    }

    return Scaffold(
      backgroundColor: Theme.of(context).cardColor,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(36),
        child: AppBar(
          leading: leading,
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

                  bool selected = false;
                  if (channelPageModel.selecting) {
                    selected =
                        channelPageModel.selectedBlockIndex.contains(index);
                  }

                  Widget widget = Block(
                    blocks[index],
                    NodeType.channel,
                    index,
                    showCreator: showCreator,
                    onLongPress: () {
                      if (!channelPageModel.selecting) {
                        channelPageModel.onLongPressBlock(index);
                      }
                    },
                    selecting: channelPageModel.selecting,
                    selected: selected,
                    onSelected: channelPageModel.onSelectBlock,
                  );

                  if (channelPageModel.showTooltipIndex == index) {
                    widget = SimpleTooltip(
                        backgroundColor: Theme.of(context).canvasColor,
                        ballonPadding:
                            EdgeInsets.symmetric(vertical: 6, horizontal: 4),
                        arrowTipDistance: 4,
                        arrowLength: 10,
                        content: Container(
                          child: Wrap(
                            children: [
                              TooltipButton(
                                  icon: Icons.copy,
                                  text: tr("channel.block.tooltip.copy"),
                                  onTap: () {
                                    channelPageModel.onTapCopyBlock(index);
                                  }),
                              TooltipButton(
                                  icon: Icons.check_box_outlined,
                                  text: tr("channel.block.tooltip.select"),
                                  onTap: () {
                                    channelPageModel.onTapSelection(index);
                                  }),
                            ],
                          ),
                        ),
                        borderColor: Colors.transparent,
                        borderRadius: 5,
                        show: true,
                        child: widget);
                  }

                  return Container(
                    padding: EdgeInsets.symmetric(
                      vertical: 2,
                      horizontal: 20,
                    ),
                    child: widget,
                  );
                }, childCount: blocks.length),
              ),
            ],
          ),
        ),
        widget,
      ]),
    );
  }
}
