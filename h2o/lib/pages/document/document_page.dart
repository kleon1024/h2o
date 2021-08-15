import 'dart:convert';

import 'package:enum_to_string/enum_to_string.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:h2o/bean/block.dart';
import 'package:h2o/bean/chart.dart';
import 'package:h2o/bean/chart_series.dart';
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
        "editingBlock.id:" + documentPageModel.editingBlock.uuid.toString());
    debugPrint(
        "editingPreBlockID:" + documentPageModel.editingPreBlockID.toString());
    debugPrint("editingIndex:" + documentPageModel.editingIndex.toString());
    debugPrint("editState:" + documentPageModel.editState.toString());
    debugPrint("editBlock.type:" + documentPageModel.editingBlock.type);

    List<BlockBean> blocks = [];
    if (blockDao.blockMap.containsKey(documentPageModel.node.uuid)) {
      blocks = blockDao.blockMap[documentPageModel.node.uuid]!;
    }
    debugPrint("---");
    return Scaffold(
      backgroundColor: Theme.of(context).cardColor,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(36),
        child: AppBar(
          title: Text(documentPageModel.node.name),
          actions: [
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
                    if (documentPageModel.focusMap[blocks[index].uuid] !=
                        null) {
                      focusNode = documentPageModel
                          .focusMap[blocks[index].uuid]![blocks[index].type]!;
                    }

                    return Container(
                        padding: EdgeInsets.symmetric(
                          vertical: 0,
                          horizontal: 20,
                        ),
                        child: Block(blocks[index], NodeType.document, index,
                            showCreator: false,
                            editing: documentPageModel.editingBlock.uuid ==
                                blocks[index].uuid,
                            handleRawKeyEvent:
                                documentPageModel.handleRawKeyEvent,
                            focusNode: focusNode,
                            onTextFieldChanged:
                                documentPageModel.onTextFieldChanged,
                            onSubmitCreateBlock:
                                documentPageModel.onSubmitCreateBlock,
                            editingController: documentPageModel
                                .editingController, onEnter: () {
                          documentPageModel.onSubmitCreateBlock();
                        }, onClick: () {
                          documentPageModel.onTapBlock(blocks[index], index);
                        }));
                  }, childCount: blocks.length),
                ),
                SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    if (documentPageModel.editingNew) {
                      return Container(
                          padding: EdgeInsets.symmetric(
                            vertical: 0,
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
                                    documentPageModel.editingBlock.uuid]![
                                documentPageModel.editingBlock.type],
                            onTextFieldChanged:
                                documentPageModel.onTextFieldChanged,
                            editingController:
                                documentPageModel.editingController,
                            onEnter: () {
                              documentPageModel.onSubmitCreateBlock();
                            },
                            onSubmitCreateBlock:
                                documentPageModel.onSubmitCreateBlock,
                          ));
                    } else {
                      return Container();
                    }
                  }, childCount: 1),
                ),
                SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    return Container(
                        padding: EdgeInsets.symmetric(
                          vertical: 0,
                          horizontal: 20,
                        ),
                        child: Block(
                          BlockBean(
                            uuid: "123",
                            nodeId: "123",
                            type: EnumToString.convertToString(
                              BlockType.chart,
                            ),
                            properties: jsonEncode(ChartBean(
                                table: "7945c9b5-54da-4138-8b29-72cd57842385",
                                series: [
                                  ChartSeries(
                                    type: "line",
                                    x: "b8392c7c-653c-4f35-8fa6-9fa2b63c33aa",
                                    y: "93d4870c-a3cd-43b9-ab5b-172c2773bdba",
                                    points: [],
                                  ),
                                  ChartSeries(
                                    type: "column",
                                    x: "b8392c7c-653c-4f35-8fa6-9fa2b63c33aa",
                                    y: "1cb3594e-c412-461e-8656-4d7699acc599",
                                    points: [],
                                  ),
                                ]).toJson()),
                          ),
                          NodeType.document,
                          index,
                          showCreator: false,
                          editing: documentPageModel.editingNew,
                          handleRawKeyEvent:
                              documentPageModel.handleRawKeyEvent,
                          focusNode: documentPageModel.focusMap[
                              documentPageModel.editingBlock
                                  .uuid]![documentPageModel.editingBlock.type],
                          onTextFieldChanged:
                              documentPageModel.onTextFieldChanged,
                          editingController:
                              documentPageModel.editingController,
                          onEnter: () {
                            documentPageModel.onSubmitCreateBlock();
                          },
                          onSubmitCreateBlock:
                              documentPageModel.onSubmitCreateBlock,
                        ));
                  }, childCount: 1),
                ),
              ],
            ),
          ),
        ),
        documentPageModel.isEditing
            ? Container(
                padding: EdgeInsets.symmetric(horizontal: 20),
                height: 40,
                decoration: new BoxDecoration(
                  color: Theme.of(context).cardColor,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 25.0, // soften the shadow
                      spreadRadius: 5.0, //extend the shadow
                      offset: Offset(
                        0, // Move to right 10  horizontally
                        0, // Move to bottom 10 Vertically
                      ),
                    )
                  ],
                ),
                child: Row(
                  children: [
                    InkWell(
                      child: Icon(Icons.add, size: 16),
                      onTap: () {},
                    ),
                  ],
                ),
              )
            : Container()
      ]),
    );
  }
}
