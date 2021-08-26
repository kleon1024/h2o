import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:h2o/bean/block.dart';
import 'package:h2o/components/blocks/block.dart';
import 'package:h2o/components/buttons/bottom_sheet_button.dart';
import 'package:h2o/components/buttons/tooltip_button.dart';
import 'package:h2o/components/scroll/bouncing_scroll_view.dart';
import 'package:h2o/dao/block.dart';
import 'package:h2o/dao/node.dart';
import 'package:h2o/model/channel/channel_page.dart';
import 'package:h2o/model/channel/select_nodes_page.dart';
import 'package:h2o/model/global.dart';
import 'package:h2o/pages/channel/select_nodes_page.dart';
import 'package:h2o/pages/unified_page.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
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
      leading = InkWell(
        child: Center(
          child: Text(tr("channel.block.selection.cancel"),
              style: Theme.of(context).textTheme.bodyText1,
              overflow: TextOverflow.ellipsis),
        ),
        onTap: () {
          channelPageModel.onTapSelectionCancel();
        },
      );
    }

    Widget widget = Container(
      height: 60,
      child: Row(
        children: [
          Container(
            width: 15,
          ),
          Expanded(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 5),
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
                      EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                  fillColor: Colors.black26,
                  filled: true,
                  enabledBorder: inputBorder,
                  focusedBorder: inputBorder,
                ),
              ),
            ),
          ),
          GestureDetector(
            onTap: () {},
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 5),
              child: Icon(Icons.add_circle_outline),
            ),
          ),
          Container(
            width: 30,
          ),
        ],
      ),
    );

    if (channelPageModel.selecting) {
      Widget menu = buildForwardMenu(context, channelPageModel);
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
          children: [
            TooltipButton(
              icon: CupertinoIcons.arrowshape_turn_up_right,
              onTap: () {
                showCupertinoModalBottomSheet(
                  context: context,
                  builder: (BuildContext context) {
                    return menu;
                  },
                );
              },
            ),
            TooltipButton(
              icon: CupertinoIcons.delete,
              onTap: () {
                showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text(
                            tr("channel.block.tooltip.confirm_to_delete"),
                            style: Theme.of(context).textTheme.subtitle1),
                        actionsAlignment: MainAxisAlignment.spaceAround,
                        actions: <Widget>[
                          TextButton(
                            child: Text(
                                tr("channel.block.tooltip.delete.cancel"),
                                style: Theme.of(context).textTheme.bodyText1),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                          TextButton(
                            child: Text(
                                tr("channel.block.tooltip.delete.confirm"),
                                style: Theme.of(context).textTheme.bodyText1),
                            onPressed: () {
                              Navigator.of(context).pop();
                              channelPageModel.onTapDeleteSelectedBlocks();
                            },
                          ),
                        ],
                      );
                    });
              },
            ),
          ],
        ),
      );
    }

    return UnifiedPage(
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(36),
          child: AppBar(
            elevation: 0,
            backgroundColor: Colors.transparent,
            leading: leading,
            title: Text(channelPageModel.node.name),
            actions: [
              IconButton(onPressed: () {}, icon: Icon(Icons.group)),
            ],
          ),
        ),
        body: GestureDetector(
          onTap: () {
            FocusScope.of(context).requestFocus(FocusNode());
          },
          child: Column(
            children: [
              Expanded(
                child: EasyRefresh.builder(
                  footer: MaterialFooter(),
                  controller: channelPageModel.refreshController,
                  enableControlFinishLoad: true,
                  builder: (context, physics, header, footer) {
                    return BouncingScrollView(
                      scrollBar: true,
                      reverse: true,
                      slivers: [
                        SliverList(
                          delegate:
                              SliverChildBuilderDelegate((context, index) {
                            Widget tooltipDelete = TooltipButton(
                                icon: CupertinoIcons.delete,
                                text: tr("channel.block.tooltip.delete"),
                                onTap: () {
                                  showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title: Text(
                                              tr(
                                                  "channel.block.tooltip.confirm_to_delete"),
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .subtitle1),
                                          content: SingleChildScrollView(
                                            child: ListBody(
                                              children: <Widget>[
                                                Text(blocks[index].text),
                                              ],
                                            ),
                                          ),
                                          actionsAlignment:
                                              MainAxisAlignment.spaceAround,
                                          actions: <Widget>[
                                            TextButton(
                                              child: Text(
                                                  tr(
                                                      "channel.block.tooltip.delete.cancel"),
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .bodyText1),
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                              },
                                            ),
                                            TextButton(
                                              child: Text(
                                                  tr(
                                                      "channel.block.tooltip.delete.confirm"),
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .bodyText1),
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                                channelPageModel
                                                    .onTapDeleteBlock(index);
                                              },
                                            ),
                                          ],
                                        );
                                      });
                                });

                            bool showCreator = true;
                            if (index < blocks.length - 1) {
                              if (blocks[index + 1].authorId ==
                                      blocks[index].authorId &&
                                  blocks[index].createdAt -
                                          blocks[index + 1].createdAt <
                                      1000 * 60) {
                                showCreator = false;
                              }
                            }

                            bool selected = false;
                            if (channelPageModel.selecting) {
                              selected = channelPageModel.selectedBlockIndex
                                  .contains(index);
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
                                  backgroundColor: Colors.black54,
                                  ballonPadding: EdgeInsets.symmetric(
                                      vertical: 6, horizontal: 4),
                                  arrowTipDistance: 4,
                                  arrowLength: 10,
                                  tooltipDirection: TooltipDirection.vertical,
                                  content: Container(
                                    child: Wrap(
                                      children: [
                                        TooltipButton(
                                            icon: Icons.copy,
                                            text: tr(
                                                "channel.block.tooltip.copy"),
                                            onTap: () {
                                              channelPageModel
                                                  .onTapCopyBlock(index);
                                            }),
                                        tooltipDelete,
                                        TooltipButton(
                                            icon: Icons.check_box_outlined,
                                            text: tr(
                                                "channel.block.tooltip.select"),
                                            onTap: () {
                                              channelPageModel
                                                  .onTapSelection(index);
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
                        footer!,
                      ],
                    );
                  },
                  onLoad: channelPageModel.onLoad,
                  onRefresh: channelPageModel.onRefresh,
                ),
              ),
              widget,
            ],
          ),
        ),
      ),
    );
  }

  Widget buildForwardMenu(
      BuildContext context, ChannelPageModel channelPageModel) {
    final globalModel = Provider.of<GlobalModel>(context);
    return Container(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          BottomSheetButton(
              text: tr("channel.block.selection.copy_to_doc"),
              onTap: () {
                Navigator.of(context).pop();
                Navigator.of(context).push(
                  CupertinoPageRoute(builder: (ctx) {
                    return ChangeNotifierProvider(
                        create: (_) => SelectNodesPageModel(
                              context,
                              globalModel,
                              type: NodeType.document,
                              teamId: channelPageModel.node.teamId,
                            ),
                        child: SelectNodesPage(
                          onCancel: channelPageModel.onTapSelectionCancel,
                          onConfirm: channelPageModel.onCopyBlocksToDoc,
                        ));
                  }),
                );
              }),
          BottomSheetButton(
              text: tr("channel.block.selection.move_to_doc"),
              onTap: () {
                Navigator.of(context).pop();
                Navigator.of(context).push(
                  CupertinoPageRoute(builder: (ctx) {
                    return ChangeNotifierProvider(
                      create: (_) => SelectNodesPageModel(
                        context,
                        globalModel,
                        type: NodeType.document,
                        teamId: channelPageModel.node.teamId,
                      ),
                      child: SelectNodesPage(
                        onCancel: channelPageModel.onTapSelectionCancel,
                        // TODO: Move multiple blocks to doc
                        onConfirm: (_) {},
                      ),
                    );
                  }),
                );
              }),
          BottomSheetButton(
              text:
                  tr("channel.block.selection.combine_and_forward_to_channel"),
              onTap: () {
                Navigator.of(context).pop();
                Navigator.of(context).push(
                  CupertinoPageRoute(builder: (ctx) {
                    return ChangeNotifierProvider(
                      create: (_) => SelectNodesPageModel(
                        context,
                        globalModel,
                        type: NodeType.document,
                        teamId: channelPageModel.node.teamId,
                      ),
                      child: SelectNodesPage(
                        onCancel: channelPageModel.onTapSelectionCancel,
                        // TODO: Move multiple blocks to channel
                        onConfirm: (_) {},
                      ),
                    );
                  }),
                );
              }),
          BottomSheetButton(
              text:
                  tr("channel.block.selection.separate_and_forward_to_channel"),
              onTap: () {
                Navigator.of(context).pop();
                Navigator.of(context).push(
                  CupertinoPageRoute(builder: (ctx) {
                    return ChangeNotifierProvider(
                      create: (_) => SelectNodesPageModel(
                        context,
                        globalModel,
                        type: NodeType.document,
                        teamId: channelPageModel.node.teamId,
                      ),
                      child: SelectNodesPage(
                        onCancel: channelPageModel.onTapSelectionCancel,
                        onConfirm: channelPageModel.onCopyBlocksToChannel,
                      ),
                    );
                  }),
                );
              }),
          Container(
            height: 1,
            width: double.infinity,
            color: Theme.of(context).highlightColor,
          ),
          BottomSheetButton(
              text: tr("channel.block.selection.cancel"),
              onTap: () {
                Navigator.of(context).pop();
              }),
          Container(
            padding: EdgeInsets.symmetric(vertical: 10),
          )
        ],
      ),
    );
  }
}
