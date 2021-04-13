import 'package:enum_to_string/enum_to_string.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:h2o/bean/block.dart';
import 'package:h2o/bean/node.dart';
import 'package:h2o/dao/block.dart';
import 'package:h2o/global/consts.dart';
import 'package:h2o/model/global.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

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
  String editingPreBlockID = EMPTY_UUID;
  String editingPosBlockID = EMPTY_UUID;
  BlockBean editingBlock = BlockBean();
  int editingIndex = 0;
  String lastText = "";
  String lastLastText = "";
  bool deleteGuard = true;

  Future updateFocus() async {
    List<BlockBean> blocks = this.globalModel.blockDao!.blockMap[node.id]!;
    blocks.forEach((block) {
      if (!focusMap.containsKey(block.id)) {
        focusMap[block.id] = FocusNode();
      }
    });
  }

  onSubmitCreateBlock(BlockBean block) async {
    // TODO: atomic
    this.onCreateBlock(true);
    focusMap[EMPTY_UUID]!.requestFocus();
  }

  Future setEditingNewPrePosBlockID() async {
    if (editingNew) {
      List<BlockBean> blocks = this.globalModel.blockDao!.blockMap[node.id]!;
      editingIndex = blocks.length;
      if (blocks.length > 0) {
        editingPreBlockID = blocks[blocks.length - 1].id;
      } else {
        editingPosBlockID = EMPTY_UUID;
      }
      editingPosBlockID = EMPTY_UUID;
    }
  }

  onTapEmptyArea() {
    if (editingNew) {
      if (editingController.text.isNotEmpty) {
        this.onCreateBlock(false);
      }
      editingNew = false;
    } else {
      editingNew = true;
      this.setEditingNewPrePosBlockID();
      focusMap[EMPTY_UUID]!.requestFocus();
    }
    editingController.text = "";
    editingBlock = BlockBean();
    debugPrint("tapped");
    notifyListeners();
  }

  onCreateBlock(bool submit) async {
    if (editingNew) {
      List<BlockBean> blocks = this.globalModel.blockDao!.blockMap[node.id]!;
      String uuidString = Uuid().v4();
      BlockBean? blockBean = BlockBean(
          id: uuidString,
          type: EnumToString.convertToString(BlockType.text),
          text: editingController.text,
          preBlockID: editingPreBlockID,
          posBlockID: editingPosBlockID);
      this
          .globalModel
          .blockDao!
          .blockMap[node.id]!
          .insert(editingIndex, blockBean);
      blocks[editingIndex - 1].posBlockID = blockBean.id;
      focusMap[blockBean.id] = FocusNode();
      setEditingNewPrePosBlockID();
      editingController.text = "";
      notifyListeners();

      globalModel.blockDao!.sendBlockEvent(
          BlockBean.copyFrom(blockBean), BlockEventType.create, node);
    } else {
      if (submit) {
        List<BlockBean> blocks = this.globalModel.blockDao!.blockMap[node.id]!;

        bool patchBlockBean = editingController.text != editingBlock.text;
        if (patchBlockBean) {
          BlockBean? blockBean = editingBlock;
          blockBean.text = editingController.text;
          blocks[editingIndex] = blockBean;
          globalModel.blockDao!.sendBlockEvent(
              BlockBean.copyFrom(blockBean), BlockEventType.patch, node);
        }

        String uuidString = Uuid().v4();
        BlockBean? newBlockBean = BlockBean(
            id: uuidString,
            type: EnumToString.convertToString(BlockType.text),
            text: "",
            preBlockID: editingBlock.id,
            posBlockID: editingPosBlockID);
        blocks[editingIndex].posBlockID = newBlockBean.id;
        blocks.insert(editingIndex + 1, newBlockBean);
        globalModel.blockDao!.sendBlockEvent(
            BlockBean.copyFrom(newBlockBean), BlockEventType.create, node);

        focusMap[newBlockBean.id] = FocusNode();
        editingIndex += 1;
        editingBlock = blocks[editingIndex];
        editingController.text = editingBlock.text;
        editingPreBlockID = editingBlock.preBlockID;
        editingPosBlockID = editingBlock.posBlockID;
        focusMap[editingBlock.id]!.requestFocus();
        if (editingIndex < blocks.length - 1) {
          blocks[editingIndex + 1].preBlockID = newBlockBean.id;
        }

        notifyListeners();
      }
    }
    notifyListeners();
  }

  onTextFieldChanged(String text) {}

  onTapBlock(BlockBean block, index) {
    debugPrint("onTapBlock:");
    debugPrint(block.id.toString());
    if (block.id != EMPTY_UUID) {
      editingNew = false;
      editingBlock = block;
      editingController.text = editingBlock.text;
      editingIndex = index;
      editingPreBlockID = editingBlock.preBlockID;
      editingPosBlockID = editingBlock.posBlockID;

      focusMap[block.id]!.requestFocus();
      notifyListeners();
    }
  }

  handleRawKeyEvent(RawKeyEvent event) {
    if (!(event is RawKeyUpEvent)) return;
    debugPrint(event.toString());

    if (event.logicalKey == LogicalKeyboardKey.backspace) {
      if (editingController.text.isEmpty) {
        debugPrint("--------------empty backspace detected--------------");
        List<BlockBean> blocks = this.globalModel.blockDao!.blockMap[node.id]!;
        if (editingNew) {
          editingNew = false;
          editingIndex = blocks.length - 1;
          if (editingIndex >= 0) {
            editingBlock = blocks[editingIndex];
            editingController.text = editingBlock.text;
            editingPreBlockID = editingBlock.preBlockID;
            editingPosBlockID = editingBlock.posBlockID;
            focusMap[editingBlock.id]!.requestFocus();
          }
        } else if (editingIndex >= 0 && editingIndex < blocks.length) {
          focusMap.remove(editingBlock.id);
          globalModel.blockDao!.sendBlockEvent(
              BlockBean.copyFrom(editingBlock), BlockEventType.delete, node);

          if (editingIndex == 0) {
            if (blocks.length > 1) {
              blocks[editingIndex + 1].preBlockID = EMPTY_UUID;
            }
            editingIndex -= 1;
            editingBlock = BlockBean();
            editingController.text = editingBlock.text;
            editingPreBlockID = editingBlock.preBlockID;
            editingPosBlockID = editingBlock.posBlockID;
          } else {
            blocks[editingIndex - 1].posBlockID = editingBlock.posBlockID;
            if (editingIndex < blocks.length - 1) {
              blocks[editingIndex + 1].preBlockID = editingBlock.preBlockID;
            }
            editingIndex -= 1;
            editingBlock = blocks[editingIndex];
            editingController.text = editingBlock.text;
            editingPreBlockID = editingBlock.preBlockID;
            editingPosBlockID = editingBlock.posBlockID;
            focusMap[editingBlock.id]!.requestFocus();
          }
          blocks.removeAt(editingIndex + 1);
        }
        notifyListeners();
      }
    }
  }
}
