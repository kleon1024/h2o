import 'package:enum_to_string/enum_to_string.dart';
import 'package:flutter/cupertino.dart';
import 'package:h2o/api/api.dart';
import 'package:h2o/bean/block.dart';
import 'package:h2o/bean/node.dart';
import 'package:h2o/dao/block.dart';
import 'package:h2o/dao/node.dart';
import 'package:h2o/dao/transaction.dart';
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
      this.globalModel.blockDao!.loadBlocks(node);
    }
  }

  final controller = TextEditingController();
  final focusNode = FocusNode();

  onTapCreateBlock(String text) async {
    controller.text = "";
    if (text.trim().isNotEmpty) {
      List<BlockBean> blocks = this.globalModel.blockDao!.blockMap[node.uuid]!;

      String uuidString = Uuid().v4();
      BlockBean blockBean = BlockBean(
        nodeId: node.uuid,
        uuid: uuidString,
        text: text,
        type: EnumToString.convertToString(BlockType.text),
        previousId: EMPTY_UUID,
        authorId: this.globalModel.userDao!.user!.id,
        createdAt: DateTime.now().toUtc().millisecondsSinceEpoch,
        updatedAt: DateTime.now().toUtc().millisecondsSinceEpoch,
      );
      blocks.insert(0, blockBean);
      notifyListeners();
      this.globalModel.transactionDao!.transaction(Transaction(
          [Operation(OperationType.InsertChannelBlock, block: blockBean)]));
    }
    focusNode.requestFocus();
  }

  onChangeToDocument() async {
    node.type = EnumToString.convertToString(NodeType.document);
    // TODO Guarantee
    Api.patchNode(node.uuid,
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
