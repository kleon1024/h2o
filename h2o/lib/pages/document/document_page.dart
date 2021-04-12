import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:h2o/bean/block.dart';
import 'package:h2o/components/blocks/block.dart';
import 'package:h2o/components/scroll/bouncing_scroll_view.dart';
import 'package:h2o/dao/block.dart';
import 'package:h2o/dao/node.dart';
import 'package:h2o/model/document/document_page.dart';
import 'package:provider/provider.dart';

class DocumentPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final documentPageModel = Provider.of<DocumentPageModel>(context);
    final blockDao = Provider.of<BlockDao>(context);

    debugPrint("editingNew:" + documentPageModel.editingNew.toString());
    debugPrint(
        "editingBlock.id:" + documentPageModel.editingBlock.id.toString());
    debugPrint(
        "editingPreBlockID:" + documentPageModel.editingPreBlockID.toString());
    debugPrint(
        "editingPosBlockID:" + documentPageModel.editingPosBlockID.toString());
    debugPrint("editingIndex:" + documentPageModel.editingIndex.toString());
    debugPrint("---");

    List<BlockBean> blocks = [];
    if (blockDao.blockMap.containsKey(documentPageModel.node.id)) {
      blocks = blockDao.blockMap[documentPageModel.node.id]!;
    }

    return Scaffold(
      backgroundColor: Theme.of(context).cardColor,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(36),
        child: AppBar(
          title: Text(documentPageModel.node.name),
          actions: [
            IconButton(onPressed: () {}, icon: Icon(CupertinoIcons.search)),
            IconButton(onPressed: () {}, icon: Icon(CupertinoIcons.group)),
          ],
        ),
      ),
      body: Column(children: [
        Expanded(
          child: GestureDetector(
            onTap: documentPageModel.onTapEmptyArea,
            child: BouncingScrollView(
              scrollBar: true,
              slivers: [
                SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    return Container(
                        padding: EdgeInsets.symmetric(
                          vertical: 3,
                          horizontal: 20,
                        ),
                        child: Block(
                          blocks[index],
                          NodeType.document,
                          index,
                          showCreator: false,
                          editing: documentPageModel.editingBlock.id ==
                              blocks[index].id,
                        ));
                  }, childCount: blocks.length),
                ),
                SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    if (documentPageModel.editingNew) {
                      return Container(
                          padding: EdgeInsets.symmetric(
                            vertical: 3,
                            horizontal: 20,
                          ),
                          child: Block(
                            documentPageModel.editingBlock,
                            NodeType.document,
                            index,
                            showCreator: false,
                            editing: documentPageModel.editingNew,
                          ));
                    } else {
                      return Container();
                    }
                  }, childCount: 1),
                ),
              ],
            ),
          ),
        ),
      ]),
    );
  }
}
