import 'dart:convert';

import 'package:enum_to_string/enum_to_string.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:h2o/bean/block.dart';
import 'package:h2o/bean/chart.dart';
import 'package:h2o/bean/node.dart';
import 'package:h2o/dao/block.dart';
import 'package:h2o/dao/transaction.dart';
import 'package:h2o/global/constants.dart';
import 'package:h2o/model/global.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

enum EditState {
  Idle,
  NotEmpty,
  EmptyText,
  EmptyBullet,
  ReadyToDelete,
  ReadyToBeText,
}

class DocumentPageModel extends ChangeNotifier {
  BuildContext context;
  GlobalModel globalModel;

  NodeBean node;
  // Is Editing New Block
  bool editingNewLast = false;
  String editingPreBlockID = EMPTY_UUID;
  String editingPosBlockID = EMPTY_UUID;
  BlockBean editingBlock;
  int editingIndex = 0;
  EditState editState = EditState.Idle;
  bool editingNewLastGuard = false;

  bool isEditing = false;

  DocumentPageModel(this.context, this.node, {bool update = true})
      : globalModel = Provider.of<GlobalModel>(context),
        editingBlock = BlockBean(nodeId: node.uuid) {
    if (update) {
      this.globalModel.blockDao!.loadDocumentBlocks(node);
    } else {
      updateFocus();
    }
    this
        .globalModel
        .registerCallback(EventType.NODE_BLOCKS_UPDATED, updateFocus);
  }

  final editingController = TextEditingController();

  final focusMap = {};

  FocusNode newFocusNode(BlockBean bean) {
    var focusNode = FocusNode();
    focusNode.addListener(() {
      if (focusNode.hasFocus) {
        debugPrint("has focus node");
      } else {
        // Save Editing Block On Blur
        debugPrint("loss focus node");
        debugPrint("editingNewLast=" + editingNewLast.toString());
        debugPrint(bean.index.toString() + "=" + json.encode(bean.toJson()));
        if (bean.uuid == EMPTY_UUID) {
          if (bean.text.length > 0) {
            List<BlockBean> blocks =
                this.globalModel.blockDao!.blockMap[node.uuid]!;
            String uuidString = Uuid().v4();
            bean.uuid = uuidString;
            focusMap[bean.uuid] = {bean.type: newFocusNode(bean)};
            blocks.insert(bean.index, bean);
            this.globalModel.transactionDao!.transaction(Transaction([
                  Operation(OperationType.InsertDocumentBlock,
                      block: BlockBean.fromJson(bean.toJson()))
                ]));
          }
        } else {
          this.globalModel.transactionDao!.transaction(Transaction([
                Operation(OperationType.UpdateDocumentBlock,
                    block: BlockBean.fromJson(bean.toJson()))
              ]));
        }
      }
    });
    return focusNode;
  }

  Future updateFocus() async {
    List<BlockBean> blocks = this.globalModel.blockDao!.blockMap[node.uuid]!;
    blocks.forEach((block) {
      if (!focusMap.containsKey(block.uuid)) {
        focusMap[block.uuid] = {block.type: newFocusNode(block)};
      }
    });
  }

  onSubmitCreateBlock() async {
    debugPrint("onSubmitCreateBlock");
    List<BlockBean> blocks = this.globalModel.blockDao!.blockMap[node.uuid]!;
    isEditing = true;
    if (editingNewLast) {
      // Create a new block
      editingBlock.text = editingController.text.substring(1);
      String uuidString = Uuid().v4();
      editingBlock.uuid = uuidString;
      focusMap[editingBlock.uuid] = {
        editingBlock.type: newFocusNode(editingBlock)
      };
      this.globalModel.transactionDao!.transaction(Transaction([
            Operation(OperationType.InsertDocumentBlock,
                block: BlockBean.fromJson(editingBlock.toJson()))
          ]));
      blocks.insert(editingIndex, editingBlock);
      onEditingLastNewBlock();
      // if (editingBlock.type ==
      //     EnumToString.convertToString(BlockType.bulletedList)) {
      //   editState = EditState.ReadyToBeText;
      // } else {
      //   editingBlock.type = EnumToString.convertToString(BlockType.text);
      //   editState = editState = EditState.ReadyToDelete;
      // }
    } else {
      if (editingIndex < blocks.length - 1) {
        String uuidString = Uuid().v4();
        BlockBean newBlockBean = BlockBean(
          uuid: uuidString,
          type: EnumToString.convertToString(BlockType.text),
          text: "",
          nodeId: node.uuid,
          previousId: editingBlock.uuid,
          createdAt: DateTime.now().toUtc().millisecondsSinceEpoch,
          updatedAt: DateTime.now().toUtc().millisecondsSinceEpoch,
          authorId: globalModel.userDao!.user!.id,
          index: editingIndex + 1,
        );

        // editState = EditState.ReadyToDelete;
        // if (editingBlock.type ==
        //     EnumToString.convertToString(BlockType.bulletedList)) {
        //   newBlockBean.type =
        //       EnumToString.convertToString(BlockType.bulletedList);
        //   editState = EditState.ReadyToBeText;
        // }

        blocks.insert(editingIndex + 1, newBlockBean);
        this.globalModel.transactionDao!.transaction(Transaction([
              Operation(OperationType.InsertDocumentBlock,
                  block: BlockBean.fromJson(newBlockBean.toJson()))
            ]));

        focusMap[newBlockBean.uuid] = {
          newBlockBean.type: newFocusNode(newBlockBean)
        };
        editingIndex += 1;
        editingBlock = blocks[editingIndex];
        editingController.text = INVISIBLE + editingBlock.text;
        focusMap[editingBlock.uuid]![editingBlock.type]!.requestFocus();
        blocks[editingIndex + 1].previousId = newBlockBean.uuid;
      } else {
        onEditingLastNewBlock();
      }
    }

    notifyListeners();
  }

  onInsertChart(ChartBean chart) async {
    List<BlockBean> blocks = this.globalModel.blockDao!.blockMap[node.uuid]!;
    String uuidString = Uuid().v4();
    BlockBean? newBlockBean = BlockBean(
      uuid: uuidString,
      type: EnumToString.convertToString(BlockType.chart),
      text: "",
      nodeId: node.uuid,
      previousId: editingPreBlockID,
      createdAt: DateTime.now().toUtc().millisecondsSinceEpoch,
      updatedAt: DateTime.now().toUtc().millisecondsSinceEpoch,
      authorId: globalModel.userDao!.user!.id,
      properties: jsonEncode(chart.toJson()),
    );

    if (editingIndex == blocks.length) {
      blocks.insert(editingIndex, newBlockBean);
    } else {
      blocks.insert(editingIndex + 1, newBlockBean);
    }

    this.globalModel.transactionDao!.transaction(Transaction([
          Operation(OperationType.InsertDocumentBlock,
              block: BlockBean.fromJson(newBlockBean.toJson()))
        ]));
    notifyListeners();
  }

  onEditingLastNewBlock() {
    List<BlockBean> blocks = this.globalModel.blockDao!.blockMap[node.uuid]!;
    editingNewLast = true;
    isEditing = true;
    editState = EditState.EmptyText;
    editingController.text = INVISIBLE;
    String previousId = EMPTY_UUID;
    editingIndex = 0;
    if (blocks.length > 0) {
      previousId = blocks.last.uuid;
      editingIndex = blocks.length;
    }
    BlockBean block = BlockBean(
      uuid: EMPTY_UUID,
      nodeId: node.uuid,
      type: EnumToString.convertToString(BlockType.text),
      previousId: previousId,
      text: "",
      createdAt: DateTime.now().toUtc().millisecondsSinceEpoch,
      updatedAt: DateTime.now().toUtc().millisecondsSinceEpoch,
      authorId: globalModel.userDao!.user!.id,
      index: editingIndex,
    );
    editingBlock = block;
    focusMap[editingBlock.uuid] = {
      editingBlock.type: newFocusNode(editingBlock)
    };
    focusMap[editingBlock.uuid]![editingBlock.type]!.requestFocus();
  }

  onTapEmptyArea() {
    if (editingNewLast) {
      editingNewLast = false;
      isEditing = false;
    } else {
      onEditingLastNewBlock();
    }
    debugPrint("onTapEmptyArea");
    notifyListeners();
  }

  onTextFieldChanged(String text) {
    debugPrint("onTextFieldChanged len: " +
        text.length.toString() +
        " text:" +
        text.toString());

    if (text.length == 0) {
      debugPrint("---deleting block");
      List<BlockBean> blocks = this.globalModel.blockDao!.blockMap[node.uuid]!;
      if (editingNewLast) {
        debugPrint("--- new line");
        editingNewLast = false;
        if (blocks.length > 0) {
          editingBlock = blocks.last;
          editingController.text = INVISIBLE + editingBlock.text;
          editingIndex -= 1;
          isEditing = true;
          focusMap[editingBlock.uuid]![editingBlock.type]!.requestFocus();
        } else {
          editingIndex = -1;
          isEditing = false;
        }
      } else {
        focusMap.remove(editingBlock.uuid);
        this.globalModel.transactionDao!.transaction(Transaction([
              Operation(OperationType.DeleteDocumentBlock,
                  block: BlockBean.copyFrom(editingBlock))
            ]));

        if (editingIndex == 0) {
          if (blocks.length > 1) {
            blocks[editingIndex + 1].previousId = EMPTY_UUID;
          }
          editingIndex -= 1;
          editingController.text = INVISIBLE;
        } else {
          if (editingIndex < blocks.length - 1) {
            blocks[editingIndex + 1].previousId = editingBlock.previousId;
          }
          editingIndex -= 1;
          editingBlock = blocks[editingIndex];
          editingController.text = INVISIBLE + editingBlock.text;
          focusMap[editingBlock.uuid]![editingBlock.type]!.requestFocus();
        }
        blocks.removeAt(editingIndex + 1);
      }
      notifyListeners();
    }

    if (text.endsWith("\n")) {
      editingController.text = editingController.text.trimRight();
      editingBlock.text = this.editingController.text.substring(1);
      this.onSubmitCreateBlock();
    }
    if (text == INVISIBLE + "# ") {
      editingBlock.type = EnumToString.convertToString(BlockType.heading1);
      editingController.text = INVISIBLE;
      focusMap[editingBlock.uuid]![editingBlock.type] =
          newFocusNode(editingBlock);
    } else if (text == INVISIBLE + "## ") {
      editingBlock.type = EnumToString.convertToString(BlockType.heading2);
      editingController.text = INVISIBLE;
      focusMap[editingBlock.uuid]![editingBlock.type] =
          newFocusNode(editingBlock);
    } else if (text == INVISIBLE + "### ") {
      editingBlock.type = EnumToString.convertToString(BlockType.heading3);
      editingController.text = INVISIBLE;
      focusMap[editingBlock.uuid]![editingBlock.type] =
          newFocusNode(editingBlock);
    } else if (text == INVISIBLE + "* ") {
      editingBlock.type = EnumToString.convertToString(BlockType.bulletedList);
      editingController.text = INVISIBLE;
      focusMap[editingBlock.uuid]![editingBlock.type] =
          newFocusNode(editingBlock);
    }
    editingController.selection = TextSelection.fromPosition(
        TextPosition(offset: editingController.text.length));
    if (editingController.text.isNotEmpty) {
      editState = EditState.NotEmpty;
    } else if (editingBlock.type ==
        EnumToString.convertToString(BlockType.bulletedList)) {
      editState = EditState.EmptyBullet;
    } else {
      editState = EditState.ReadyToDelete;
    }

    editingBlock.text = editingController.text.substring(1);

    notifyListeners();
    focusMap[editingBlock.uuid]![editingBlock.type]!.requestFocus();
  }

  onTapBlock(BlockBean block, index) {
    debugPrint("onTapBlock:" + block.uuid.toString());
    isEditing = true;
    if (block.uuid != EMPTY_UUID) {
      if (editingNewLast && editingNewLastGuard) {
        editingNewLastGuard = false;
        return;
      }
      editingNewLast = false;
      editingBlock = block;
      editingController.text = INVISIBLE + editingBlock.text;
      editingIndex = index;
      // if (editingController.text.isNotEmpty) {
      //   editState = EditState.NotEmpty;
      // } else if (editingBlock.type ==
      //     EnumToString.convertToString(BlockType.bulletedList)) {
      //   editState = EditState.ReadyToBeText;
      // } else {
      //   editState = EditState.ReadyToDelete;
      // }
      focusMap[block.uuid]![block.type]!.requestFocus();
      notifyListeners();
    }
  }

  handleRawKeyEvent(RawKeyEvent event) {
    debugPrint(event.toString());
  }

  onReorder(int oldIndex, int newIndex) {
    debugPrint("move " + oldIndex.toString() + "->" + newIndex.toString());
    if (oldIndex == newIndex) return;
    List<BlockBean> blocks = this.globalModel.blockDao!.blockMap[node.uuid]!;
    BlockBean movingBlock = blocks[oldIndex];
    String oldPreviousId = movingBlock.previousId;

    List<Operation> ops = [];
    // Remove at oldIndex
    if (oldIndex < blocks.length - 1) {
      blocks[oldIndex + 1].previousId = movingBlock.previousId;
    }

    // Insert at newIndex
    if (oldIndex < newIndex) {
      movingBlock.previousId = blocks[newIndex].uuid;
      if (newIndex < blocks.length - 1) {
        blocks[newIndex + 1].previousId = movingBlock.uuid;
      }
    } else {
      movingBlock.previousId = blocks[newIndex].previousId;
      blocks[newIndex].previousId = movingBlock.uuid;
    }

    String newPreviousId = movingBlock.previousId;

    BlockBean blockBean = blocks.removeAt(oldIndex);
    blockBean.previousId = oldPreviousId;
    ops.add(Operation(OperationType.DeleteDocumentBlock,
        block: BlockBean.fromJson(blockBean.toJson())));
    blockBean.previousId = newPreviousId;
    blocks.insert(newIndex, blockBean);
    ops.add(Operation(OperationType.InsertDocumentBlock,
        block: BlockBean.fromJson(blockBean.toJson())));

    this.globalModel.transactionDao!.transaction(Transaction(ops));

    notifyListeners();
  }

  onReorderStarted(int index) {
    this.isEditing = false;
    this.editingNewLast = false;
    notifyListeners();
  }

  onCancelEditing() {
    isEditing = false;
    editingNewLast = false;
    notifyListeners();
  }
}
