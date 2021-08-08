import 'dart:async';

import 'package:channel/channel.dart';
import 'package:dio/dio.dart';
import 'package:enum_to_string/enum_to_string.dart';
import 'package:flutter/cupertino.dart';
import 'package:h2o/api/api.dart';
import 'package:h2o/bean/block.dart';
import 'package:h2o/bean/node.dart';
import 'package:h2o/model/global.dart';

enum BlockType {
  text,
  heading1,
  heading2,
  heading3,
  heading4,
  heading5,
  heading6,
  bulletedList,
  numberedList,
  checkbox,
  image,
  table,
  tableReference,
  barChart,
  referenceBlock,
  referenceNode,
}

enum BlockEventType { create, patch, delete }

class BlockEvent {
  BlockBean block;
  BlockEventType type;
  NodeBean? node;

  BlockEvent(this.block, this.type, {this.node});
}

class BlockDao extends ChangeNotifier {
  BuildContext? context;
  Map<String, List<BlockBean>> blockMap = {};
  CancelToken cancelToken = CancelToken();
  GlobalModel? globalModel;
  final channel = Channel<BlockEvent>();
  int backOffSeconds = 0;

  setContext(BuildContext context, GlobalModel globalModel) async {
    if (this.context == null) {
      this.context = context;
      this.globalModel = globalModel;
      globalModel.blockDao = this;
      while (true) {
        final event = await channel.receive();
        if (!event.isClosed) {
          // TODO block until success
          bool status = false;
          while (!status) {
            status = await Future.delayed(Duration(seconds: backOffSeconds),
                () async {
              return await this.sendBlockBean(event.data!);
            });
            if (status) {
              this.backOffSeconds = 0;
            } else {
              if (this.backOffSeconds <= 0) {
                this.backOffSeconds = 1;
              } else {
                this.backOffSeconds *= 4;
              }
            }
          }
        }
      }
    }
  }

  sendBlockEvent(
      BlockBean blockBean, BlockEventType blockEventType, NodeBean nodeBean) {
    debugPrint("sendBlockEvent:" +
        EnumToString.convertToString(blockEventType) +
        " " +
        blockBean.uuid +
        " pre:" +
        blockBean.previousId);
    this.channel.send(BlockEvent(blockBean, blockEventType, node: nodeBean));
  }

  Future<bool> sendBlockBean(BlockEvent blockEvent) async {
    BlockBean blockBean = blockEvent.block;
    BlockBean? retBlockBean;
    if (blockEvent.type == BlockEventType.create) {
      retBlockBean = await Api.createNodeBlock(
        blockEvent.node!.uuid,
        data: {
          "id": blockBean.id,
          "text": blockBean.text,
          "type": blockBean.type,
          "previous": blockBean.previousId,
        },
        options: this.globalModel!.userDao!.accessTokenOptions(),
      );
      if (retBlockBean != null) {
        notifyListeners();
        return true;
      }
      return false;
    } else if (blockEvent.type == BlockEventType.patch) {
      retBlockBean = await Api.patchBlock(
        blockBean.uuid,
        data: {
          "text": blockBean.text,
          "type": blockBean.type,
          "previous": blockBean.previousId,
        },
        options: this.globalModel!.userDao!.accessTokenOptions(),
      );
      if (retBlockBean != null) {
        notifyListeners();
        return true;
      }
      return false;
    } else if (blockEvent.type == BlockEventType.delete) {
      retBlockBean = await Api.deleteBlock(
        blockBean.uuid,
        options: this.globalModel!.userDao!.accessTokenOptions(),
      );
      if (retBlockBean != null) {
        notifyListeners();
        return true;
      }
      return false;
    }
    return true;
  }

  // Future updateBlocks(NodeBean nodeBean) async {
  //   List<BlockBean>? blocks = await Api.listNodeBlocks(
  //     nodeBean.uuid,
  //     data: {"offset": 0, "limit": 100},
  //     options: this.globalModel!.userDao!.accessTokenOptions(),
  //     cancelToken: cancelToken,
  //   );
  //
  //   if (blocks != null) {
  //     if (blocks.length == 0) {
  //       blockMap[nodeBean.uuid] = [];
  //       return;
  //     }
  //     Map<String, BlockBean> preBlockMap = {};
  //     blocks.forEach((block) {
  //       preBlockMap[block.previousId] = block;
  //     });
  //     BlockBean block = preBlockMap[EMPTY_UUID]!;
  //     int cnt = 0;
  //     List<BlockBean> orderedBlocks = [];
  //     debugPrint("blocks length:" + blocks.length.toString());
  //     while (block.posBlockID != EMPTY_UUID) {
  //       cnt += 1;
  //       debugPrint(cnt.toString() + ":" + block.id);
  //       if (cnt >= blocks.length) {
  //         break;
  //       }
  //       orderedBlocks.add(block);
  //       block = preBlockMap[block.id]!;
  //     }
  //     orderedBlocks.add(block);
  //     blockMap[nodeBean.uuid] = orderedBlocks;
  //
  //     this.globalModel!.triggerCallback(EventType.NODE_BLOCKS_UPDATED);
  //     notifyListeners();
  //   }
  // }

  updateBlock(NodeBean node, BlockBean updatedBlock) {
    List<BlockBean> blocks = blockMap[node.id]!;
    for (int i = 0; i < blocks.length; i++) {
      if (blocks[i].id == updatedBlock.id) {
        blocks[i] = updatedBlock;
        break;
      }
    }
  }

  @override
  void dispose() {
    super.dispose();
    if (!cancelToken.isCancelled) cancelToken.cancel();
  }
}
