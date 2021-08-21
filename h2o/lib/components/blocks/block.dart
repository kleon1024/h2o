import 'package:enum_to_string/enum_to_string.dart';
import 'package:flutter/material.dart';
import 'package:h2o/bean/block.dart';
import 'package:h2o/components/blocks/bulleted_list_block.dart';
import 'package:h2o/components/blocks/chart_block.dart';
import 'package:h2o/components/blocks/numbered_list_block.dart';
import 'package:h2o/components/blocks/text_block.dart';
import 'package:h2o/dao/block.dart';
import 'package:h2o/dao/node.dart';
import 'package:timeago/timeago.dart' as timeago;

class Block extends StatelessWidget {
  final BlockBean blockBean;
  final bool showCreator;
  final bool editing;
  final NodeType nodeType;
  final int index;
  final Function(RawKeyEvent event)? handleRawKeyEvent;
  final FocusNode? focusNode;
  final TextEditingController? editingController;
  final Function(String text)? onTextFieldChanged;
  final Function()? onSubmitCreateBlock;
  final Function()? onEnter;
  final Function()? onClick;
  final Function()? onLongPress;
  final bool selected;
  final bool selecting;
  final Function(int index, bool value)? onSelected;

  const Block(
    this.blockBean,
    this.nodeType,
    this.index, {
    this.showCreator = false,
    this.editing = false,
    this.handleRawKeyEvent,
    this.focusNode,
    this.onTextFieldChanged,
    this.onSubmitCreateBlock,
    this.editingController,
    this.onEnter,
    this.onClick,
    this.onLongPress,
    this.selected = false,
    this.selecting = false,
    this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    Widget block;
    BlockType blockType =
        EnumToString.fromString(BlockType.values, blockBean.type)!;
    switch (blockType) {
      case BlockType.text:
      case BlockType.heading1:
      case BlockType.heading2:
      case BlockType.heading3:
      case BlockType.heading4:
        block = TextBlock(blockBean,
            editing: editing,
            handleRawKeyEvent: handleRawKeyEvent,
            focusNode: focusNode,
            onTextFieldChanged: onTextFieldChanged,
            onSubmitCreateBlock: onSubmitCreateBlock,
            editingController: editingController);
        break;
      case BlockType.bulletedList:
        block = BulletedListBlock(
          blockBean,
          editing: editing,
        );
        break;
      case BlockType.numberedList:
        block = NumberedListBlock(
          text: "Numbered List",
        );
        break;
      case BlockType.chart:
        block = ChartBlock(blockBean);
        break;
      default:
        block = Container(
          child: Text("Unmatched version"),
        );
    }

    block = GestureDetector(
      onTap: onClick,
      onLongPress: onLongPress,
      child: block,
    );

    if (nodeType == NodeType.document) {
      return Container(width: double.infinity, child: block);
    }

    Widget checkbox = Container();
    if (this.selecting) {
      checkbox = Container(
        height: 25,
        alignment: Alignment.center,
        child: Checkbox(
            visualDensity: VisualDensity.compact,
            value: this.selected,
            onChanged: (val) {
              if (this.onSelected != null) {
                this.onSelected!(index, val!);
              }
            }),
      );
    }

    if (this.showCreator) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            child: CircleAvatar(),
          ),
          Expanded(
            child: Container(
                padding: EdgeInsets.symmetric(horizontal: 6),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 4),
                        child: Row(
                          children: [
                            Text(
                              "Author",
                              style: Theme.of(context).textTheme.caption!.merge(
                                  TextStyle(fontWeight: FontWeight.bold)),
                            ),
                            Text(" "),
                            Text(
                              timeago.format(
                                  DateTime.fromMillisecondsSinceEpoch(
                                      blockBean.updatedAt)),
                              style: Theme.of(context).textTheme.caption,
                            ),
                          ],
                        ),
                      ),
                      block,
                    ])),
          ),
          checkbox,
        ],
      );
    } else {
      return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          width: 38,
        ),
        Expanded(
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 4),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 4),
              child: block,
            ),
          ),
        ),
        checkbox,
      ]);
    }
  }
}
