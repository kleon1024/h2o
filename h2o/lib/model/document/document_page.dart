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
  bool editingNew = false;
  String editingPreBlockID = EMPTY_UUID;
  String editingPosBlockID = EMPTY_UUID;
  BlockBean editingBlock;
  int editingIndex = 0;
  EditState editState = EditState.Idle;
  bool editingNewGuard = false;

  bool get isEditing =>
      editingBlock.uuid == EMPTY_UUID && editingNew ||
      editingBlock.uuid != EMPTY_UUID;

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
  final focusMap = {
    EMPTY_UUID: {
      EnumToString.convertToString(BlockType.text): FocusNode(),
    }
  };

  Future updateFocus() async {
    List<BlockBean> blocks = this.globalModel.blockDao!.blockMap[node.uuid]!;
    blocks.forEach((block) {
      if (!focusMap.containsKey(block.uuid)) {
        focusMap[block.uuid] = {block.type: FocusNode()};
      }
    });
  }

  onSubmitCreateBlock() async {
    // TODO: atomic
    debugPrint("onSubmitCreateBlock");
    this.onCreateBlock(true);
    focusMap[EMPTY_UUID]![editingBlock.type]!.requestFocus();
    editingNewGuard = true;
  }

  Future setEditingNewPrePosBlockID() async {
    if (editingNew) {
      List<BlockBean> blocks = this.globalModel.blockDao!.blockMap[node.uuid]!;
      editingIndex = blocks.length;
      if (blocks.length > 0) {
        editingPreBlockID = blocks.last.uuid;
      } else {
        editingPreBlockID = EMPTY_UUID;
      }
    }
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

    if (editingNew) {
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

  onTapEmptyArea() {
    if (editingNew) {
      if (editingController.text.isNotEmpty) {
        this.onCreateBlock(false);
      }
      editingNew = false;
    } else {
      // Editing an existing block then save on tap empty area & create a new block
      if (editingBlock.uuid != EMPTY_UUID) {
        List<BlockBean> blocks =
            this.globalModel.blockDao!.blockMap[node.uuid]!;
        bool patchBlockBean = editingController.text != editingBlock.text;
        if (patchBlockBean) {
          BlockBean? blockBean = editingBlock;
          blockBean.text = editingController.text;
          blocks[editingIndex] = blockBean;
          this.globalModel.transactionDao!.transaction(Transaction([
                Operation(OperationType.UpdateDocumentBlock,
                    block: BlockBean.fromJson(blockBean.toJson()))
              ]));
        }
      }
      editingNew = true;
      this.setEditingNewPrePosBlockID();
      focusMap[EMPTY_UUID]![EnumToString.convertToString(BlockType.text)]!
          .requestFocus();
      editState = EditState.EmptyText;
    }
    editingController.text = "";
    editingBlock = BlockBean(
      nodeId: node.uuid,
      updatedAt: DateTime.now().toUtc().millisecondsSinceEpoch,
      authorId: globalModel.userDao!.user!.id,
    );
    debugPrint("onTapEmptyArea");
    notifyListeners();
  }

  // Submit: enter key to submit
  onCreateBlock(bool submit) async {
    if (editingNew) {
      List<BlockBean> blocks = this.globalModel.blockDao!.blockMap[node.uuid]!;
      String uuidString = Uuid().v4();
      BlockBean? blockBean = BlockBean(
        uuid: uuidString,
        nodeId: node.uuid,
        type: editingBlock.type,
        text: editingController.text,
        previousId: editingPreBlockID,
        updatedAt: DateTime.now().toUtc().millisecondsSinceEpoch,
        authorId: globalModel.userDao!.user!.id,
      );
      this
          .globalModel
          .blockDao!
          .blockMap[node.uuid]!
          .insert(editingIndex, blockBean);

      focusMap[blockBean.uuid] = {blockBean.type: FocusNode()};
      setEditingNewPrePosBlockID();
      editingController.text = "";

      if (editingBlock.type ==
          EnumToString.convertToString(BlockType.bulletedList)) {
        editState = EditState.ReadyToBeText;
      } else {
        editingBlock.type = EnumToString.convertToString(BlockType.text);
        editState = editState = EditState.ReadyToDelete;
      }
      if (!submit) {
        editState = EditState.Idle;
      }
      notifyListeners();

      this.globalModel.transactionDao!.transaction(Transaction([
            Operation(OperationType.InsertDocumentBlock,
                block: BlockBean.fromJson(blockBean.toJson()))
          ]));
    } else {
      if (submit) {
        List<BlockBean> blocks =
            this.globalModel.blockDao!.blockMap[node.uuid]!;

        bool patchBlockBean = editingController.text != editingBlock.text;
        if (patchBlockBean) {
          BlockBean? blockBean = editingBlock;
          blockBean.text = editingController.text;
          blocks[editingIndex] = blockBean;

          this.globalModel.transactionDao!.transaction(Transaction([
                Operation(OperationType.UpdateDocumentBlock,
                    block: BlockBean.fromJson(blockBean.toJson()))
              ]));
        }

        String uuidString = Uuid().v4();
        BlockBean? newBlockBean = BlockBean(
          uuid: uuidString,
          type: EnumToString.convertToString(BlockType.text),
          text: "",
          nodeId: node.uuid,
          previousId: editingBlock.uuid,
          updatedAt: DateTime.now().toUtc().millisecondsSinceEpoch,
          authorId: globalModel.userDao!.user!.id,
        );

        editState = EditState.ReadyToDelete;
        if (editingBlock.type ==
            EnumToString.convertToString(BlockType.bulletedList)) {
          newBlockBean.type =
              EnumToString.convertToString(BlockType.bulletedList);
          editState = EditState.ReadyToBeText;
        }

        blocks.insert(editingIndex + 1, newBlockBean);
        this.globalModel.transactionDao!.transaction(Transaction([
              Operation(OperationType.InsertDocumentBlock,
                  block: BlockBean.fromJson(newBlockBean.toJson()))
            ]));

        focusMap[newBlockBean.uuid] = {newBlockBean.type: FocusNode()};
        editingIndex += 1;
        editingBlock = blocks[editingIndex];
        editingController.text = editingBlock.text;
        editingPreBlockID = editingBlock.previousId;
        // editingPosBlockID = editingBlock.posBlockID;
        focusMap[editingBlock.uuid]![editingBlock.type]!.requestFocus();
        if (editingIndex < blocks.length - 1) {
          blocks[editingIndex + 1].previousId = newBlockBean.uuid;
        }
        notifyListeners();
      }
    }
    notifyListeners();
  }

  onTextFieldChanged(String text) {
    debugPrint("onTextFieldChanged:" + text.toString());
    if (text.endsWith("\n")) {
      this.editingController.text = text.trimRight();
      this.onSubmitCreateBlock();
    }
    if (text == "# ") {
      editingBlock.type = EnumToString.convertToString(BlockType.heading1);
      editingController.text = "";
      focusMap[editingBlock.uuid]![editingBlock.type] = FocusNode();
    } else if (text == "## ") {
      editingBlock.type = EnumToString.convertToString(BlockType.heading2);
      editingController.text = "";
      focusMap[editingBlock.uuid]![editingBlock.type] = FocusNode();
    } else if (text == "### ") {
      editingBlock.type = EnumToString.convertToString(BlockType.heading3);
      editingController.text = "";
      focusMap[editingBlock.uuid]![editingBlock.type] = FocusNode();
    } else if (text == "* ") {
      editingBlock.type = EnumToString.convertToString(BlockType.bulletedList);
      editingController.text = "";
      focusMap[editingBlock.uuid]![editingBlock.type] = FocusNode();
    }
    editingController.selection = TextSelection.fromPosition(
        TextPosition(offset: editingController.text.length));
    if (editingController.text.isNotEmpty) {
      editState = EditState.NotEmpty;
    } else if (editingBlock.type ==
        EnumToString.convertToString(BlockType.bulletedList)) {
      editState = EditState.EmptyBullet;
    } else {
      editState = EditState.EmptyText;
    }

    notifyListeners();
    focusMap[editingBlock.uuid]![editingBlock.type]!.requestFocus();
  }

  onTapBlock(BlockBean block, index) {
    debugPrint("onTapBlock:" + block.uuid.toString());
    if (block.uuid != EMPTY_UUID) {
      if (editingNew && editingNewGuard) {
        editingNewGuard = false;
        return;
      }
      editingNew = false;
      editingBlock = block;
      editingController.text = editingBlock.text;
      editingIndex = index;
      editingPreBlockID = editingBlock.previousId;
      // editingPosBlockID = editingBlock.posBlockID;
      if (editingController.text.isNotEmpty) {
        editState = EditState.NotEmpty;
      } else if (editingBlock.type ==
          EnumToString.convertToString(BlockType.bulletedList)) {
        editState = EditState.ReadyToBeText;
      } else {
        editState = EditState.ReadyToDelete;
      }

      focusMap[block.uuid]![block.type]!.requestFocus();
      notifyListeners();
    }
  }

  handleRawKeyEvent(RawKeyEvent event) {
    if (!(event is RawKeyUpEvent)) return;
    debugPrint(event.toString());

    if (event.logicalKey == LogicalKeyboardKey.backspace) {
      if (editingController.text.isEmpty) {
        if (editState == EditState.EmptyText) {
          editState = EditState.ReadyToDelete;
          return;
        } else if (editState == EditState.EmptyBullet) {
          editState = EditState.ReadyToBeText;
          return;
        } else if (editState == EditState.ReadyToBeText) {
          editState = EditState.ReadyToDelete;
          editingBlock.type = EnumToString.convertToString(BlockType.text);
          focusMap[editingBlock.uuid]![editingBlock.type] = FocusNode();
          focusMap[editingBlock.uuid]![editingBlock.type]!.requestFocus();
          notifyListeners();
          return;
        } else if (editState != EditState.ReadyToDelete) {
          return;
        }

        debugPrint("--------------empty backspace detected--------------");
        List<BlockBean> blocks =
            this.globalModel.blockDao!.blockMap[node.uuid]!;
        if (editingNew) {
          editingNew = false;
          editingIndex = blocks.length - 1;
          if (editingIndex >= 0) {
            editingBlock = blocks[editingIndex];
            editingController.text = editingBlock.text;
            editingPreBlockID = editingBlock.previousId;
            focusMap[editingBlock.uuid]![editingBlock.type]!.requestFocus();
          }
        } else if (editingIndex >= 0 && editingIndex < blocks.length) {
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
            editingBlock = BlockBean(
              nodeId: node.uuid,
              updatedAt: DateTime.now().toUtc().millisecondsSinceEpoch,
              authorId: globalModel.userDao!.user!.id,
            );
            editingController.text = editingBlock.text;
            editingPreBlockID = editingBlock.previousId;
            // editingPosBlockID = editingBlock.posBlockID;
          } else {
            // blocks[editingIndex - 1].posBlockID = editingBlock.posBlockID;
            if (editingIndex < blocks.length - 1) {
              blocks[editingIndex + 1].previousId = editingBlock.previousId;
            }
            editingIndex -= 1;
            editingBlock = blocks[editingIndex];
            editingController.text = editingBlock.text;
            editingPreBlockID = editingBlock.previousId;
            // editingPosBlockID = editingBlock.posBlockID;
            focusMap[editingBlock.uuid]![editingBlock.type]!.requestFocus();
          }
          blocks.removeAt(editingIndex + 1);
        }
        notifyListeners();
      }
    }
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
}
