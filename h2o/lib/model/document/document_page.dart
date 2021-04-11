import 'package:enum_to_string/enum_to_string.dart';
import 'package:flutter/cupertino.dart';
import 'package:h2o/api/api.dart';
import 'package:h2o/bean/block.dart';
import 'package:h2o/bean/node.dart';
import 'package:h2o/dao/block.dart';
import 'package:h2o/global/consts.dart';
import 'package:h2o/model/global.dart';
import 'package:provider/provider.dart';

class DocumentPageModel extends ChangeNotifier {
  BuildContext context;
  GlobalModel globalModel;

  NodeBean node;

  DocumentPageModel(this.context, this.node)
      : globalModel = Provider.of<GlobalModel>(context) {
    this.globalModel.blockDao!.updateBlocks(node);
    this
        .globalModel
        .registerCallback(EventType.NODE_BLOCKS_UPDATED, updateFocus);
  }

  final editingController = TextEditingController();
  final focusMap = {
    EMPTY_UUID: FocusNode(),
  };

  // New
  bool editingNew = false;
  String editingBlockID = "";
  BlockBean editingBlock = BlockBean();

  Future updateFocus() async {
    List<BlockBean> blocks = this.globalModel.blockDao!.blockMap[node.id]!;
    blocks.forEach((block) {
      if (!focusMap.containsKey(block.id)) {
        focusMap[block.id] = FocusNode();
      }
    });
  }

  onSubmitCreateBlock(BlockBean block) async {
    this.onCreateBlock(true);
    focusMap[""]!.requestFocus();
  }

  onTapEmptyArea() {
    if (editingNew) {
      if (editingController.text.isNotEmpty) {
        this.onCreateBlock(false);
      }
      editingNew = false;
    } else {
      editingNew = true;
      focusMap[""]!.requestFocus();
    }
    editingBlockID = "";
    editingController.text = "";
    editingBlock = BlockBean();
    notifyListeners();
  }

  onCreateBlock(bool submit) async {
    if (editingNew) {
      notifyListeners();
      BlockBean? blockBean = await Api.createNodeBlock(
        node.id,
        data: {
          "text": editingController.text,
          "type": EnumToString.convertToString(BlockType.text),
        },
        options: this.globalModel.userDao!.accessTokenOptions(),
      );
      if (blockBean != null) {
        editingController.text = "";
        this.globalModel.blockDao!.updateBlocks(node);
      }
    } else {
      // TODO check if modify and modify
      if (submit) {
        // createNodeBlockAfter
      }
    }
    editingBlockID = "";
    notifyListeners();
  }

  onTextFieldChanged(String text) {}

  onTapBlock(BlockBean block) {
    if (block.id.isNotEmpty) {
      editingNew = false;
      editingBlockID = block.id;
      editingBlock = block;
      editingController.text = editingBlock.text;
      focusMap[block.id]!.requestFocus();
      notifyListeners();
    }
  }
}
