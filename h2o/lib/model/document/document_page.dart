import 'package:enum_to_string/enum_to_string.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:h2o/api/api.dart';
import 'package:h2o/bean/block.dart';
import 'package:h2o/bean/node.dart';
import 'package:h2o/dao/block.dart';
import 'package:h2o/dao/node.dart';
import 'package:h2o/global/constants.dart';
import 'package:h2o/model/channel/channel_page.dart';
import 'package:h2o/model/global.dart';
import 'package:h2o/pages/channel/channel_page.dart';
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

  DocumentPageModel(this.context, this.node, {bool update = true})
      : globalModel = Provider.of<GlobalModel>(context) {
    if (update) {
      // this.globalModel.blockDao!.updateBlocks(node);
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

  // New
  bool editingNew = false;
  String editingPreBlockID = EMPTY_UUID;
  String editingPosBlockID = EMPTY_UUID;
  BlockBean editingBlock = BlockBean();
  int editingIndex = 0;
  EditState editState = EditState.Idle;
  bool editingNewGuard = false;

  Future updateFocus() async {
    List<BlockBean> blocks = this.globalModel.blockDao!.blockMap[node.id]!;
    blocks.forEach((block) {
      if (!focusMap.containsKey(block.id)) {
        focusMap[block.uuid] = {block.type: FocusNode()};
      }
    });
  }

  onSubmitCreateBlock(BlockBean block) async {
    // TODO: atomic
    debugPrint("onSubmitCreateBlock");
    this.onCreateBlock(true);
    focusMap[EMPTY_UUID]![editingBlock.type]!.requestFocus();
    editingNewGuard = true;
  }

  Future setEditingNewPrePosBlockID() async {
    if (editingNew) {
      List<BlockBean> blocks = this.globalModel.blockDao!.blockMap[node.id]!;
      editingIndex = blocks.length;
      if (blocks.length > 0) {
        editingPreBlockID = blocks[blocks.length - 1].uuid;
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
      if (editingBlock.id != EMPTY_UUID) {
        List<BlockBean> blocks = this.globalModel.blockDao!.blockMap[node.id]!;
        bool patchBlockBean = editingController.text != editingBlock.text;
        if (patchBlockBean) {
          BlockBean? blockBean = editingBlock;
          blockBean.text = editingController.text;
          blocks[editingIndex] = blockBean;
          globalModel.blockDao!.sendBlockEvent(
              BlockBean.copyFrom(blockBean), BlockEventType.patch, node);
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
      updatedAt: DateTime.now().toUtc().millisecondsSinceEpoch,
      authorId: globalModel.userDao!.user!.id,
    );
    debugPrint("onTapEmptyArea");
    notifyListeners();
  }

  onCreateBlock(bool submit) async {
    if (editingNew) {
      List<BlockBean> blocks = this.globalModel.blockDao!.blockMap[node.id]!;
      String uuidString = Uuid().v4();
      BlockBean? blockBean = BlockBean(
        uuid: uuidString,
        type: editingBlock.type,
        text: editingController.text,
        previousId: editingPreBlockID,
        updatedAt: DateTime.now().toUtc().millisecondsSinceEpoch,
        authorId: globalModel.userDao!.user!.id,
      );
      this
          .globalModel
          .blockDao!
          .blockMap[node.id]!
          .insert(editingIndex, blockBean);
      // if (blocks.length > 1) {
      //   blocks[editingIndex - 1].posBlockID = blockBean.id;
      // }
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
          uuid: uuidString,
          type: EnumToString.convertToString(BlockType.text),
          text: "",
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

        // blocks[editingIndex].posBlockID = newBlockBean.id;
        blocks.insert(editingIndex + 1, newBlockBean);
        globalModel.blockDao!.sendBlockEvent(
            BlockBean.copyFrom(newBlockBean), BlockEventType.create, node);

        focusMap[newBlockBean.uuid] = {newBlockBean.type: FocusNode()};
        editingIndex += 1;
        editingBlock = blocks[editingIndex];
        editingController.text = editingBlock.text;
        editingPreBlockID = editingBlock.previousId;
        // editingPosBlockID = editingBlock.posBlockID;
        focusMap[editingBlock.id]![editingBlock.type]!.requestFocus();
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
    if (text == "# ") {
      editingBlock.type = EnumToString.convertToString(BlockType.heading1);
      editingController.text = "";
      focusMap[editingBlock.id]![editingBlock.type] = FocusNode();
    } else if (text == "## ") {
      editingBlock.type = EnumToString.convertToString(BlockType.heading2);
      editingController.text = "";
      focusMap[editingBlock.id]![editingBlock.type] = FocusNode();
    } else if (text == "### ") {
      editingBlock.type = EnumToString.convertToString(BlockType.heading3);
      editingController.text = "";
      focusMap[editingBlock.id]![editingBlock.type] = FocusNode();
    } else if (text == "* ") {
      editingBlock.type = EnumToString.convertToString(BlockType.bulletedList);
      editingController.text = "";
      focusMap[editingBlock.id]![editingBlock.type] = FocusNode();
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
    focusMap[editingBlock.id]![editingBlock.type]!.requestFocus();
  }

  onTapBlock(BlockBean block, index) {
    debugPrint("onTapBlock:" + block.id.toString());
    if (block.id != EMPTY_UUID) {
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

      focusMap[block.id]![block.type]!.requestFocus();
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
          focusMap[editingBlock.id]![editingBlock.type] = FocusNode();
          focusMap[editingBlock.id]![editingBlock.type]!.requestFocus();
          notifyListeners();
          return;
        } else if (editState != EditState.ReadyToDelete) {
          return;
        }

        debugPrint("--------------empty backspace detected--------------");
        List<BlockBean> blocks = this.globalModel.blockDao!.blockMap[node.id]!;
        if (editingNew) {
          editingNew = false;
          editingIndex = blocks.length - 1;
          if (editingIndex >= 0) {
            editingBlock = blocks[editingIndex];
            editingController.text = editingBlock.text;
            editingPreBlockID = editingBlock.previousId;
            // editingPosBlockID = editingBlock.posBlockID;
            focusMap[editingBlock.id]![editingBlock.type]!.requestFocus();
          }
        } else if (editingIndex >= 0 && editingIndex < blocks.length) {
          focusMap.remove(editingBlock.id);
          globalModel.blockDao!.sendBlockEvent(
              BlockBean.copyFrom(editingBlock), BlockEventType.delete, node);

          if (editingIndex == 0) {
            if (blocks.length > 1) {
              blocks[editingIndex + 1].previousId = EMPTY_UUID;
            }
            editingIndex -= 1;
            editingBlock = BlockBean(
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
            focusMap[editingBlock.id]![editingBlock.type]!.requestFocus();
          }
          blocks.removeAt(editingIndex + 1);
        }
        notifyListeners();
      }
    }
  }

  onChangeToChannel() async {
    node.type = EnumToString.convertToString(NodeType.channel);
    // TODO Guarantee
    Api.patchNode(node.uuid,
        data: {"type": node.type},
        options: this.globalModel.userDao!.accessTokenOptions());

    Navigator.pop(context);
    Navigator.of(context).push(
      CupertinoPageRoute(builder: (ctx) {
        return ChangeNotifierProvider(
            create: (_) => ChannelPageModel(context, node, update: false),
            child: ChannelPage());
      }),
    );
  }

  onReorder(int oldIndex, int newIndex) {
    debugPrint("move " + oldIndex.toString() + "->" + newIndex.toString());
    if (oldIndex == newIndex) return;
    List<BlockBean> blocks = this.globalModel.blockDao!.blockMap[node.id]!;
    BlockBean movingBlock = blocks[oldIndex];
    if (oldIndex > 0 && oldIndex != newIndex + 1) {
      // blocks[oldIndex - 1].posBlockID = movingBlock.posBlockID;
      this.globalModel.blockDao!.sendBlockEvent(
          BlockBean.copyFrom(blocks[oldIndex - 1]), BlockEventType.patch, node);
    }
    if (oldIndex < blocks.length - 1 && newIndex != oldIndex + 1) {
      blocks[oldIndex + 1].previousId = movingBlock.previousId;
      this.globalModel.blockDao!.sendBlockEvent(
          BlockBean.copyFrom(blocks[oldIndex + 1]), BlockEventType.patch, node);
    }

    if (oldIndex < newIndex) {
      if (newIndex == oldIndex + 1) {
        blocks[newIndex].previousId = movingBlock.previousId;
      }
      movingBlock.previousId = blocks[newIndex].uuid;
      // movingBlock.posBlockID = blocks[newIndex].posBlockID;
      // blocks[newIndex].posBlockID = movingBlock.id;
      if (newIndex < blocks.length - 1) {
        blocks[newIndex + 1].previousId = movingBlock.uuid;
        this.globalModel.blockDao!.sendBlockEvent(
            BlockBean.copyFrom(blocks[newIndex + 1]),
            BlockEventType.patch,
            node);
      }
    } else {
      if (oldIndex == newIndex + 1) {
        // blocks[newIndex].posBlockID = movingBlock.posBlockID;
      }
      movingBlock.previousId = blocks[newIndex].previousId;
      // movingBlock.posBlockID = blocks[newIndex].id;
      blocks[newIndex].previousId = movingBlock.uuid;
      if (newIndex > 0) {
        // blocks[newIndex - 1].posBlockID = movingBlock.id;
        this.globalModel.blockDao!.sendBlockEvent(
            BlockBean.copyFrom(blocks[newIndex - 1]),
            BlockEventType.patch,
            node);
      }
    }

    this.globalModel.blockDao!.sendBlockEvent(
        BlockBean.copyFrom(blocks[oldIndex]), BlockEventType.patch, node);
    this.globalModel.blockDao!.sendBlockEvent(
        BlockBean.copyFrom(blocks[newIndex]), BlockEventType.patch, node);

    BlockBean blockBean = blocks.removeAt(oldIndex);
    blocks.insert(newIndex, blockBean);
    notifyListeners();
  }
}
