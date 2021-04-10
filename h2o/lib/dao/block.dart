import 'package:dio/dio.dart';
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

class BlockDao extends ChangeNotifier {
  BuildContext? context;
  Map<String, List<BlockBean>> blockMap = {};
  CancelToken cancelToken = CancelToken();
  GlobalModel? globalModel;

  setContext(BuildContext context, GlobalModel globalModel) async {
    if (this.context == null) {
      this.context = context;
      this.globalModel = globalModel;
      globalModel.blockDao = this;
    }
  }

  Future updateBlocks(NodeBean nodeBean) async {
    List<BlockBean>? blocks = await Api.listNodeBlocks(
      nodeBean.id,
      data: {"offset": 0, "limit": 100},
      options: this.globalModel!.userDao!.accessTokenOptions(),
      cancelToken: cancelToken,
    );

    if (blocks != null) {
      blockMap[nodeBean.id] = blocks;
      this.globalModel!.triggerCallback(EventType.NODE_BLOCKS_UPDATED);
      notifyListeners();
    }
  }

  @override
  void dispose() {
    super.dispose();
    if (!cancelToken.isCancelled) cancelToken.cancel();
  }
}
