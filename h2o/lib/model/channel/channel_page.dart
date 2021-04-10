import 'package:enum_to_string/enum_to_string.dart';
import 'package:flutter/cupertino.dart';
import 'package:h2o/api/api.dart';
import 'package:h2o/bean/block.dart';
import 'package:h2o/bean/node.dart';
import 'package:h2o/dao/block.dart';
import 'package:h2o/model/global.dart';
import 'package:provider/provider.dart';

class ChannelPageModel extends ChangeNotifier {
  BuildContext context;
  GlobalModel globalModel;

  NodeBean node;

  ChannelPageModel(this.context, this.node)
      : globalModel = Provider.of<GlobalModel>(context) {
    this.globalModel.blockDao!.updateBlocks(node);
  }

  final controller = TextEditingController();
  final focusNode = FocusNode();

  onTapCreateBlock(String text) async {
    controller.text = "";
    if (text.trim().isNotEmpty) {
      BlockBean? blockBean = await Api.createNodeBlock(
        node.id,
        data: {
          "text": text,
          "type": EnumToString.convertToString(BlockType.text),
        },
        options: this.globalModel.userDao!.accessTokenOptions(),
      );
      if (blockBean != null) {
        this.globalModel.blockDao!.updateBlocks(node);
      }
    } else {
      focusNode.requestFocus();
    }
  }
}
