import 'package:enum_to_string/enum_to_string.dart';
import 'package:flutter/cupertino.dart';
import 'package:h2o/api/api.dart';
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
      focusMap[blockBean.id] = FocusNode();
      setEditingNewPrePosBlockID();
      editingController.text = "";
      notifyListeners();

      blockBean = await Api.createNodeBlock(
        node.id,
        data: {
          "id": blockBean.id,
          "text": blockBean.text,
          "type": blockBean.type,
          "preBlockID": blockBean.preBlockID,
          "posBlockID": blockBean.posBlockID,
        },
        options: this.globalModel.userDao!.accessTokenOptions(),
      );
      if (blockBean != null) {
        this.globalModel.blockDao!.updateBlock(node, blockBean);
        notifyListeners();
      }
    } else {
      if (submit) {
        List<BlockBean> blocks = this.globalModel.blockDao!.blockMap[node.id]!;

        List<Future<BlockBean?>> futures = [];

        String uuidString = Uuid().v4();
        BlockBean? newBlockBean = BlockBean(
            id: uuidString,
            type: EnumToString.convertToString(BlockType.text),
            text: "",
            preBlockID: editingBlock.id,
            posBlockID: editingPosBlockID);
        blocks.insert(editingIndex + 1, newBlockBean);
        futures.add(Api.createNodeBlock(
          node.id,
          data: {
            "id": newBlockBean.id,
            "text": newBlockBean.text,
            "type": newBlockBean.type,
            "preBlockID": newBlockBean.preBlockID,
            "posBlockID": newBlockBean.posBlockID,
          },
          options: this.globalModel.userDao!.accessTokenOptions(),
        ));

        bool patchBlockBean = editingController.text != editingBlock.text;
        if (patchBlockBean) {
          BlockBean? blockBean = editingBlock;
          blockBean.text = editingController.text;
          blocks[editingIndex] = blockBean;
          futures.add(Api.patchBlock(
            blockBean.id,
            data: {
              "text": blockBean.text,
              "type": blockBean.type,
            },
            options: this.globalModel.userDao!.accessTokenOptions(),
          ));
        }

        focusMap[newBlockBean.id] = FocusNode();
        editingIndex += 1;
        editingBlock = blocks[editingIndex];
        editingController.text = editingBlock.text;
        this.setEditingExistPrePosBlockID();
        focusMap[editingBlock.id]!.requestFocus();
        notifyListeners();

        List<BlockBean?> beans = await Future.wait(futures);

        if (patchBlockBean) {
          if (beans[1] != null) {
            this.globalModel.blockDao!.updateBlock(node, beans[1]!);
          }
        }

        if (beans[0] != null) {
          this.globalModel.blockDao!.updateBlock(node, beans[0]!);
          notifyListeners();
        }
      }
    }
    notifyListeners();
  }

  onTextFieldChanged(String text) {}

  setEditingExistPrePosBlockID() {
    editingPreBlockID = editingBlock.preBlockID;
    List<BlockBean> blocks = this.globalModel.blockDao!.blockMap[node.id]!;
    if (editingIndex < blocks.length - 1) {
      editingPosBlockID = blocks[editingIndex + 1].id;
    } else {
      editingPosBlockID = EMPTY_UUID;
    }
  }

  onTapBlock(BlockBean block, index) {
    debugPrint("onTapBlock:");
    debugPrint(block.id.toString());
    if (block.id != EMPTY_UUID) {
      editingNew = false;
      editingBlock = block;
      editingController.text = editingBlock.text;
      editingIndex = index;

      this.setEditingExistPrePosBlockID();

      focusMap[block.id]!.requestFocus();
      notifyListeners();
    }
  }
}
