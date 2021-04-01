import 'package:flutter/material.dart';
import 'package:h2o/components/blocks/bulleted_list_block.dart';
import 'package:h2o/components/blocks/heading_one_block.dart';
import 'package:h2o/components/blocks/numbered_list_block.dart';
import 'package:h2o/components/blocks/text_block.dart';
import 'package:h2o/global/enum.dart';

class Block extends StatelessWidget {
  final BlockType type;

  const Block({required this.type});

  @override
  Widget build(BuildContext context) {
    switch (this.type) {
      case BlockType.text:
        return TextBlock(text: "Hello World");
      case BlockType.h1:
        return HeadingOneBlock(text: "Heading 1");
      case BlockType.bulleted_list:
        return BulletedListBlock(text: "Bulleted List");
      case BlockType.numbered_list:
        return NumberedListBlock(text: "Numbered List");
    }
    return TextBlock(text: "Undefined Text");
  }
}
