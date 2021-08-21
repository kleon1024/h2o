import 'package:bot_toast/bot_toast.dart';
import 'package:clipboard/clipboard.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:enum_to_string/enum_to_string.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:h2o/api/api.dart';
import 'package:h2o/bean/block.dart';
import 'package:h2o/bean/node.dart';
import 'package:h2o/dao/block.dart';
import 'package:h2o/dao/node.dart';
import 'package:h2o/dao/transaction.dart';
import 'package:h2o/db/db.dart';
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

  int offset = 0;
  int limit = 20;

  ChannelPageModel(this.context, this.node, {bool update = true})
      : globalModel = Provider.of<GlobalModel>(context) {
    if (update) {
      this.globalModel.blockDao!.loadBlocks(node, offset, limit);
    }
    toolTipFocusNode.addListener(() {
      if (!toolTipFocusNode.hasFocus) {
        this.onDismissTooltip();
      }
    });
    toolTipFocusAttachment = toolTipFocusNode.attach(context);
    controller.text = node.draft;
    focusNode.addListener(() {
      if (!focusNode.hasFocus) {
        node.draft = controller.text;
        debugPrint("update draft: " + node.draft);
        DBProvider.db.updateChannelDraft(node.uuid, controller.text);
      }
    });
    if (controller.text.isNotEmpty) {
      focusNode.requestFocus();
    }
  }

  final controller = TextEditingController();
  final focusNode = FocusNode();
  bool selecting = false;
  Set<int> selectedBlockIndex = Set();
  int showTooltipIndex = -1;
  final toolTipFocusNode = FocusNode();
  late FocusAttachment toolTipFocusAttachment;
  EasyRefreshController refreshController = EasyRefreshController();

  onSelectBlock(int index, bool value) {
    debugPrint(
        "onSelectBlock:" + index.toString() + " value: " + value.toString());
    if (value) {
      selectedBlockIndex.add(index);
    } else {
      selectedBlockIndex.remove(index);
    }
    notifyListeners();
  }

  Future onLoad() async {
    offset += limit;
    await this
        .globalModel
        .blockDao!
        .loadBlocks(node, offset, limit, callback: loadCallback);
  }

  loadCallback(int length) {
    if (length < limit) {
      refreshController.finishLoad(success: true, noMore: true);
    } else {
      refreshController.finishLoad(success: true, noMore: false);
    }
  }

  Future onRefresh() async {}

  onTapSelection(int index) {
    this.selecting = true;
    this.selectedBlockIndex.clear();
    this.selectedBlockIndex.add(index);
    this.showTooltipIndex = -1;
    notifyListeners();
  }

  onLongPressBlock(int index) {
    toolTipFocusAttachment.reparent();
    toolTipFocusNode.requestFocus();
    this.showTooltipIndex = index;
    notifyListeners();
  }

  onDismissTooltip() {
    this.showTooltipIndex = -1;
    notifyListeners();
  }

  onTapCopyBlock(int index) {
    var blocks = this.globalModel.blockDao!.blockMap[node.uuid]!;
    FlutterClipboard.copy(blocks[index].text).then((value) {
      BotToast.showText(text: tr("channel.block.tooltip.copy.toast"));
    });
    this.showTooltipIndex = -1;
    notifyListeners();
  }

  onTapDeleteBlock(int index) {
    var blocks = this.globalModel.blockDao!.blockMap[node.uuid]!;
    BlockBean block = blocks.removeAt(index);
    this.globalModel.transactionDao!.transaction(Transaction([
          Operation(
            OperationType.DeleteChannelBlock,
            block: BlockBean.fromJson(block.toJson()),
          )
        ]));
    notifyListeners();
  }

  onTapDeleteSelectedBlocks() {
    Set<String> blocksToDelete = {};
    var blocks = this.globalModel.blockDao!.blockMap[node.uuid]!;
    List<Operation> ops = [];
    for (var index in this.selectedBlockIndex.toList()) {
      blocksToDelete.add(blocks[index].uuid);
      ops.add(Operation(OperationType.DeleteChannelBlock,
          block: BlockBean.fromJson(blocks[index].toJson())));
    }

    this.globalModel.transactionDao!.transaction(Transaction(ops));
    blocks.removeWhere((block) => blocksToDelete.contains(block.uuid));
    this.selecting = false;
    this.selectedBlockIndex.clear();
    notifyListeners();
  }

  onTapSelectionCancel() {
    this.selecting = false;
    this.selectedBlockIndex.clear();
    notifyListeners();
  }

  onCopyBlocksToDoc(NodeBean docNode) async {
    List<int> orderedIndex = this.selectedBlockIndex.toList();
    orderedIndex.sort();
    if (!this.globalModel.blockDao!.blockMap.containsKey(docNode.uuid)) {
      await this.globalModel.blockDao!.loadDocumentBlocks(docNode);
    }
    List<BlockBean> docBlocks =
        this.globalModel.blockDao!.blockMap[docNode.uuid]!;
    List<BlockBean> blocks =
        this.globalModel.blockDao!.blockMap[this.node.uuid]!;
    String previousId = EMPTY_UUID;
    if (docBlocks.length > 0) {
      previousId = docBlocks.last.uuid;
    }
    List<Operation> ops = [];
    for (var index in orderedIndex) {
      var newBlock = BlockBean.fromJson(blocks[index].toJson());
      newBlock.previousId = previousId;
      newBlock.uuid = Uuid().v4();
      newBlock.nodeId = docNode.uuid;
      previousId = newBlock.uuid;
      docBlocks.add(newBlock);
      ops.add(Operation(OperationType.InsertDocumentBlock,
          block: BlockBean.fromJson(newBlock.toJson())));
    }

    this.globalModel.transactionDao!.transaction(Transaction(ops));
    debugPrint(orderedIndex.toString());
    this.onTapSelectionCancel();
    Navigator.of(context).pop();
    Navigator.of(context).pop();
  }

  onCopyBlocksToChannel(NodeBean chNode) async {
    List<int> orderedIndex = this.selectedBlockIndex.toList();
    orderedIndex.sort();
    if (!this.globalModel.blockDao!.blockMap.containsKey(chNode.uuid)) {
      await this
          .globalModel
          .blockDao!
          .loadBlocks(chNode, 0, 20, callback: loadCallback);
    }
    List<BlockBean> chBlocks =
        this.globalModel.blockDao!.blockMap[chNode.uuid]!;
    List<BlockBean> blocks =
        this.globalModel.blockDao!.blockMap[this.node.uuid]!;
    List<Operation> ops = [];
    for (var index in orderedIndex) {
      var newBlock = BlockBean.fromJson(blocks[index].toJson());
      newBlock.uuid = Uuid().v4();
      newBlock.nodeId = chNode.uuid;
      chBlocks.add(newBlock);
      ops.add(Operation(OperationType.InsertChannelBlock,
          block: BlockBean.fromJson(newBlock.toJson())));
    }

    this.globalModel.transactionDao!.transaction(Transaction(ops));
    debugPrint(orderedIndex.toString());
    this.onTapSelectionCancel();
    Navigator.of(context).pop();
    Navigator.of(context).pop();
  }

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
