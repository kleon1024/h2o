import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:h2o/bean/block.dart';
import 'package:h2o/components/blocks/block.dart';
import 'package:h2o/components/blocks/chart_block.dart';
import 'package:h2o/components/buttons/insert_menu_button.dart';
import 'package:h2o/components/scroll/bouncing_scroll_view.dart';
import 'package:h2o/dao/block.dart';
import 'package:h2o/dao/node.dart';
import 'package:h2o/model/document/add_chart_page.dart';
import 'package:h2o/model/document/document_page.dart';
import 'package:h2o/model/global.dart';
import 'package:h2o/pages/document/add_chart_page.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:provider/provider.dart';
import 'package:reorderables/reorderables.dart';

class DocumentPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final documentPageModel = Provider.of<DocumentPageModel>(context);
    final blockDao = Provider.of<BlockDao>(context);
    final globalModel = Provider.of<GlobalModel>(context);

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

    Widget menu = buildInsertMenu(context, documentPageModel, globalModel);

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
                      onTap: () {
                        showCupertinoModalBottomSheet(
                            context: context,
                            builder: (BuildContext context) {
                              return menu;
                            });
                      },
                    ),
                  ],
                ),
              )
            : Container()
      ]),
    );
  }

  Widget buildInsertMenu(BuildContext context,
      DocumentPageModel documentPageModel, GlobalModel globalModel) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.symmetric(vertical: 10),
          ),
          Container(
            padding: EdgeInsets.symmetric(vertical: 5),
            child: Text(
              "Insert",
              style: Theme.of(context)
                  .textTheme
                  .subtitle1!
                  .merge(TextStyle(fontWeight: FontWeight.w500)),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Container(
              height: 1,
              width: double.infinity,
              color: Theme.of(context).highlightColor),
          Container(
            padding: EdgeInsets.symmetric(vertical: 5),
            child: Text(
              "Format",
              style: Theme.of(context).textTheme.subtitle2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Container(
            width: double.infinity,
            child: Wrap(
              alignment: WrapAlignment.start,
              // crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                InsertMenuButton(icon: Icons.title_outlined, text: "H1"),
                InsertMenuButton(icon: Icons.title_outlined, text: "H2"),
                InsertMenuButton(icon: Icons.title_outlined, text: "H3"),
                InsertMenuButton(
                    icon: Icons.format_list_bulleted_outlined,
                    text: "Bulleted List"),
                InsertMenuButton(
                    icon: Icons.format_list_numbered_outlined,
                    text: "Numbered List"),
                InsertMenuButton(
                    icon: Icons.check_box_outlined, text: "Check List"),
                InsertMenuButton(icon: Icons.code, text: "Code Block"),
                InsertMenuButton(
                    icon: Icons.format_quote_outlined, text: "Quote"),
                InsertMenuButton(icon: Icons.remove, text: "Divider"),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(vertical: 5),
            child: Text(
              "Data",
              style: Theme.of(context).textTheme.subtitle2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Container(
            width: double.infinity,
            child: Wrap(
              alignment: WrapAlignment.start,
              // crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                InsertMenuButton(
                    icon: Icons.table_chart_outlined, text: "Database"),
                InsertMenuButton(
                  icon: Icons.bar_chart_outlined,
                  text: "Bar Chart",
                  onTap: () {
                    Navigator.of(context).push(
                      CupertinoPageRoute(builder: (ctx) {
                        return ChangeNotifierProvider(
                            create: (_) => AddChartPageModel(
                                  documentPageModel.node,
                                  ChartSeriesType.column,
                                  context,
                                  globalModel,
                                  onSubmit: documentPageModel.onInsertChart,
                                ),
                            child: AddChartPage());
                      }),
                    );
                  },
                ),
                InsertMenuButton(
                  icon: Icons.show_chart,
                  text: "Line Chart",
                  onTap: () {
                    Navigator.of(context).push(
                      CupertinoPageRoute(builder: (ctx) {
                        return ChangeNotifierProvider(
                            create: (_) => AddChartPageModel(
                                  documentPageModel.node,
                                  ChartSeriesType.line,
                                  context,
                                  globalModel,
                                  onSubmit: documentPageModel.onInsertChart,
                                ),
                            child: AddChartPage());
                      }),
                    );
                  },
                )
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(vertical: 20),
          )
        ],
      ),
    );
  }
}
