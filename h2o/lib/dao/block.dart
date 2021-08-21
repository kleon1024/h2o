import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:h2o/bean/block.dart';
import 'package:h2o/bean/chart.dart';
import 'package:h2o/bean/data_point.dart';
import 'package:h2o/bean/node.dart';
import 'package:h2o/bean/row.dart';
import 'package:h2o/db/db.dart';
import 'package:h2o/global/constants.dart';
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
  chart,
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
  Map<String, ChartBean> chartBlockMap = {};
  CancelToken cancelToken = CancelToken();
  GlobalModel? globalModel;

  setContext(BuildContext context, GlobalModel globalModel) async {
    if (this.context == null) {
      this.context = context;
      this.globalModel = globalModel;
      globalModel.blockDao = this;
    }
  }

  Future loadBlocks(NodeBean node, int offset, int limit,
      {Function(int)? callback}) async {
    var blocks =
        await DBProvider.db.getBlocks(node.uuid, offset: offset, limit: limit);
    if (offset > 0) {
      this
          .blockMap[node.uuid]!
          .insertAll(this.blockMap[node.uuid]!.length, blocks);
    } else {
      this.blockMap[node.uuid] = blocks;
    }

    if (callback != null) {
      callback(blocks.length);
    }
    notifyListeners();
  }

  Future loadChartData(BlockBean block) async {
    debugPrint(block.properties);
    final chart = ChartBean.fromJson(jsonDecode(block.properties));
    for (var s in chart.series) {
      s.points.clear();
      List<RowBean> rows = await DBProvider.db.getRows(chart.table, [s.x, s.y]);
      for (var r in rows) {
        s.points.add(DataPoint(x: r.values[0], y: r.values[1] as num));
      }
    }
    this.chartBlockMap[block.uuid] = chart;
    notifyListeners();
  }

  Future loadDocumentBlocks(NodeBean node) async {
    var blocks = await DBProvider.db.getBlocks(node.uuid);
    List<BlockBean> reordered = [];
    Map<String, BlockBean> blockMap = {};
    blocks.forEach((n) {
      blockMap[n.previousId] = n;
      debugPrint(n.previousId + " : " + n.uuid);
    });
    String previousId = EMPTY_UUID;
    for (int i = 0; i < blockMap.length; i++) {
      var n = blockMap[previousId];
      if (n == null) {
        debugPrint(
            "reorder blocks unexpected previous block id: " + previousId);
      } else {
        n.index = i;
        reordered.add(n);
        previousId = n.uuid;
      }
    }
    this.blockMap[node.uuid] = reordered;
    this.globalModel!.triggerCallback(EventType.NODE_BLOCKS_UPDATED);
    notifyListeners();
  }

  // sendBlockEvent(
  //     BlockBean blockBean, BlockEventType blockEventType, NodeBean nodeBean) {
  //   debugPrint("sendBlockEvent:" +
  //       EnumToString.convertToString(blockEventType) +
  //       " " +
  //       blockBean.uuid +
  //       " pre:" +
  //       blockBean.previousId);
  //   this.channel.send(BlockEvent(blockBean, blockEventType, node: nodeBean));
  // }

  // Future<bool> sendBlockBean(BlockEvent blockEvent) async {
  //   BlockBean blockBean = blockEvent.block;
  //   BlockBean? retBlockBean;
  //   if (blockEvent.type == BlockEventType.create) {
  //     retBlockBean = await Api.createNodeBlock(
  //       blockEvent.node!.uuid,
  //       data: {
  //         "uuid": blockBean.uuid,
  //         "text": blockBean.text,
  //         "type": blockBean.type,
  //         "previous": blockBean.previousId,
  //       },
  //       options: this.globalModel!.userDao!.accessTokenOptions(),
  //     );
  //     if (retBlockBean != null) {
  //       notifyListeners();
  //       return true;
  //     }
  //     return false;
  //   } else if (blockEvent.type == BlockEventType.patch) {
  //     retBlockBean = await Api.patchBlock(
  //       blockBean.uuid,
  //       data: {
  //         "text": blockBean.text,
  //         "type": blockBean.type,
  //         "previous": blockBean.previousId,
  //       },
  //       options: this.globalModel!.userDao!.accessTokenOptions(),
  //     );
  //     if (retBlockBean != null) {
  //       notifyListeners();
  //       return true;
  //     }
  //     return false;
  //   } else if (blockEvent.type == BlockEventType.delete) {
  //     retBlockBean = await Api.deleteBlock(
  //       blockBean.uuid,
  //       options: this.globalModel!.userDao!.accessTokenOptions(),
  //     );
  //     if (retBlockBean != null) {
  //       notifyListeners();
  //       return true;
  //     }
  //     return false;
  //   }
  //   return true;
  // }

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

  // updateBlock(NodeBean node, BlockBean updatedBlock) {
  //   List<BlockBean> blocks = blockMap[node.uuid]!;
  //   for (int i = 0; i < blocks.length; i++) {
  //     if (blocks[i].uuid == updatedBlock.uuid) {
  //       blocks[i] = updatedBlock;
  //       break;
  //     }
  //   }
  // }

  @override
  void dispose() {
    super.dispose();
    if (!cancelToken.isCancelled) cancelToken.cancel();
  }
}
