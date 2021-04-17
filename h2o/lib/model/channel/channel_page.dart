import 'package:enum_to_string/enum_to_string.dart';
import 'package:flutter/cupertino.dart';
import 'package:h2o/api/api.dart';
import 'package:h2o/bean/block.dart';
import 'package:h2o/bean/node.dart';
import 'package:h2o/dao/block.dart';
import 'package:h2o/dao/node.dart';
import 'package:h2o/global/constants.dart';
import 'package:h2o/model/document/document_page.dart';
import 'package:h2o/model/global.dart';
import 'package:h2o/pages/document/document_page.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

class ChannelPageModel extends ChangeNotifier {
  BuildContext context;
  GlobalModel globalModel;

  NodeBean node;

  ChannelPageModel(this.context, this.node, {bool update = true})
      : globalModel = Provider.of<GlobalModel>(context) {
    if (update) {
      this.globalModel.blockDao!.updateBlocks(node);
    }
  }

  final controller = TextEditingController();
  final focusNode = FocusNode();

  onTapCreateBlock(String text) async {
    controller.text = "";
    if (text.trim().isNotEmpty) {
      List<BlockBean> blocks = this.globalModel.blockDao!.blockMap[node.id]!;

      String uuidString = Uuid().v4();
      String preBlockID = EMPTY_UUID;
      if (blocks.length > 0) {
        blocks.last.posBlockID = uuidString;
        preBlockID = blocks.last.id;
      }
      BlockBean blockBean = BlockBean(
        id: uuidString,
        text: text,
        type: EnumToString.convertToString(BlockType.text),
        preBlockID: preBlockID,
        posBlockID: EMPTY_UUID,
        authorID: this.globalModel.userDao!.user!.id,
        updatedAt: DateTime.now().toUtc().toString(),
      );
      blocks.add(blockBean);
      notifyListeners();
      this.globalModel.blockDao!.sendBlockEvent(
          BlockBean.copyFrom(blockBean), BlockEventType.create, node);
    }
    focusNode.requestFocus();
  }

  onChangeToDocument() async {
    node.type = EnumToString.convertToString(NodeType.document);
    // TODO Guarantee
    Api.patchNode(node.id,
        data: {"type": node.type},
        options: this.globalModel.userDao!.accessTokenOptions());

    Navigator.pop(context);
    Navigator.of(context).push(
      CupertinoPageRoute(builder: (ctx) {
        return ChangeNotifierProvider(
            create: (_) => DocumentPageModel(context, node, update: false),
            child: DocumentPage());
      }),
    );
  }
}
