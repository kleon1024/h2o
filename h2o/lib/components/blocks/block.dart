import 'package:flutter/material.dart';
import 'package:h2o/components/blocks/bulleted_list_block.dart';
import 'package:h2o/components/blocks/heading_one_block.dart';
import 'package:h2o/components/blocks/heading_three_block.dart';
import 'package:h2o/components/blocks/heading_two_block.dart';
import 'package:h2o/components/blocks/numbered_list_block.dart';
import 'package:h2o/components/blocks/text_block.dart';
import 'package:h2o/global/enum.dart';

class Block extends StatelessWidget {
  final BlockType type;
  final bool showCreator;

  const Block({required this.type, this.showCreator = false});

  @override
  Widget build(BuildContext context) {
    Widget block;
    switch (this.type) {
      case BlockType.text:
        block = TextBlock(
            editing: true,
            text:
                "Hello World Hello WorldHello WorldHello WorldHello WorldHello WorldHello WorldHello WorldHello WorldHello WorldHello WorldHello WorldHello WorldHello WorldHello WorldHello World");
        break;
      case BlockType.h1:
        block = HeadingOneBlock(text: "Heading 1");
        break;
      case BlockType.h2:
        block = HeadingTwoBlock(text: "Heading 2");
        break;
      case BlockType.h3:
        block = HeadingThreeBlock(text: "Heading 3");
        break;
      case BlockType.bulleted_list:
        block = BulletedListBlock(
            text:
                "Hello World Hello WorldHello WorldHello WorldHello WorldHello WorldHello WorldHello WorldHello WorldHello WorldHello WorldHello WorldHello WorldHello WorldHello WorldHello World");
        break;
      case BlockType.numbered_list:
        block = NumberedListBlock(text: "Numbered List");
        break;
      default:
        block = TextBlock(text: "Undefined Text");
    }

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
                      Text(
                        "Author 2021-03-19",
                        style:
                            TextStyle(height: 1.5, fontWeight: FontWeight.bold),
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
