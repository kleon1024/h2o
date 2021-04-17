import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:h2o/bean/block.dart';
import 'package:h2o/components/blocks/block.dart';
import 'package:h2o/components/scroll/bouncing_scroll_view.dart';
import 'package:h2o/dao/block.dart';
import 'package:h2o/dao/node.dart';
import 'package:h2o/model/document/document_page.dart';
import 'package:provider/provider.dart';
import 'package:reorderables/reorderables.dart';

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
    debugPrint("editState:" + documentPageModel.editState.toString());
    debugPrint("editBlock.type:" + documentPageModel.editingBlock.type);

    List<BlockBean> blocks = [];
    if (blockDao.blockMap.containsKey(documentPageModel.node.id)) {
      blocks = blockDao.blockMap[documentPageModel.node.id]!;
    }
    debugPrint("blocks:" + blocks.toString());
    debugPrint("---");
    return Scaffold(
      backgroundColor: Theme.of(context).cardColor,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(36),
        child: AppBar(
          title: Text(documentPageModel.node.name),
          actions: [
            IconButton(
                onPressed: () {
                  documentPageModel.onChangeToChannel();
                },
                icon: Icon(CupertinoIcons.number, size: 18)),
            IconButton(
                onPressed: () {}, icon: Icon(CupertinoIcons.group, size: 18)),
          ],
        ),
      ),
      body: Column(children: [
        Expanded(
          child: GestureDetector(
            onTap: documentPageModel.onTapEmptyArea,
            child: BouncingScrollView(
              scrollBar: true,
              controller: ScrollController(),
              slivers: [
                ReorderableSliverList(
                  onReorder: documentPageModel.onReorder,
                  delegate:
                      ReorderableSliverChildBuilderDelegate((context, index) {
                    FocusNode? focusNode;
                    if (documentPageModel.focusMap[blocks[index].id] != null) {
                      focusNode = documentPageModel
                          .focusMap[blocks[index].id]![blocks[index].type]!;
                    }

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
                          handleRawKeyEvent:
                              documentPageModel.handleRawKeyEvent,
                          focusNode: focusNode,
                          onTextFieldChanged:
                              documentPageModel.onTextFieldChanged,
                          onSubmitCreateBlock:
                              documentPageModel.onSubmitCreateBlock,
                          editingController:
                              documentPageModel.editingController,
                          onTap: () {
                            documentPageModel.onTapBlock(blocks[index], index);
                          },
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
                            handleRawKeyEvent:
                                documentPageModel.handleRawKeyEvent,
                            focusNode: documentPageModel.focusMap[
                                documentPageModel.editingBlock
                                    .id]![documentPageModel.editingBlock.type],
                            onTextFieldChanged:
                                documentPageModel.onTextFieldChanged,
                            onSubmitCreateBlock:
                                documentPageModel.onSubmitCreateBlock,
                            editingController:
                                documentPageModel.editingController,
                            onTap: () {
                              documentPageModel.onTapBlock(
                                  blocks[index], index);
                            },
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
