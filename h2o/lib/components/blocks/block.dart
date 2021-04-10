import 'package:enum_to_string/enum_to_string.dart';
import 'package:flutter/material.dart';
import 'package:h2o/bean/block.dart';
import 'package:h2o/components/blocks/bulleted_list_block.dart';
import 'package:h2o/components/blocks/heading_one_block.dart';
import 'package:h2o/components/blocks/heading_three_block.dart';
import 'package:h2o/components/blocks/heading_two_block.dart';
import 'package:h2o/components/blocks/numbered_list_block.dart';
import 'package:h2o/components/blocks/text_block.dart';
import 'package:h2o/dao/block.dart';
import 'package:h2o/dao/node.dart';
import 'package:h2o/model/document/document_page.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;

class Block extends StatelessWidget {
  final BlockBean blockBean;
  final bool showCreator;
  final bool editing;
  final NodeType nodeType;

  const Block(this.blockBean, this.nodeType,
      {this.showCreator = false, this.editing = false});

  @override
  Widget build(BuildContext context) {
    Widget block;
    BlockType blockType =
        EnumToString.fromString(BlockType.values, blockBean.type)!;
    switch (blockType) {
      case BlockType.text:
        block = TextBlock(blockBean, editing: editing);
        break;
      case BlockType.heading1:
        block = HeadingOneBlock(text: "Heading 1");
        break;
      case BlockType.heading2:
        block = HeadingTwoBlock(text: "Heading 2");
        break;
      case BlockType.heading3:
        block = HeadingThreeBlock(text: "Heading 3");
        break;
      case BlockType.bulletedList:
        block = BulletedListBlock(text: "Hello");
        break;
      case BlockType.numberedList:
        block = NumberedListBlock(text: "Numbered List");
        break;
      default:
        block = Container(
          child: Text("Unmatched version"),
        );
    }

    Function()? onTap;
    Function(bool)? onHover;

    if (nodeType == NodeType.document) {
      final documentPageModel = Provider.of<DocumentPageModel>(context);
      onTap = () {
        documentPageModel.onTapBlock(blockBean);
      };
    }

    block = InkWell(
      onTap: onTap,
      focusColor: Theme.of(context).cardColor,
      child: block,
    );

    if (this.showCreator) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10),
            child: CircleAvatar(),
          ),
          Expanded(
            child: Container(
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            "Author ",
                            style: TextStyle(
                                height: 1.5, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            timeago.format(DateTime.parse(blockBean.updatedAt)),
                            style: TextStyle(
                                height: 1.5, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      block,
                    ])),
          ),
        ],
      );
    } else {
      return block;
    }
  }
}
