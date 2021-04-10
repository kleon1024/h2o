import 'package:easy_localization/easy_localization.dart';
import 'package:enum_to_string/enum_to_string.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:h2o/components/scroll/bouncing_scroll_view.dart';
import 'package:h2o/dao/node.dart';
import 'package:h2o/global/icons.dart';
import 'package:h2o/model/add_node_page.dart';
import 'package:h2o/model/global.dart';
import 'package:provider/provider.dart';

class AddNodePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final globalModel = Provider.of<GlobalModel>(context);
    final addNodePageModel = Provider.of<AddNodePageModel>(context)
      ..setContext(context, globalModel);

    var bodyTestStyle = Theme.of(context).textTheme.bodyText1!;
    if (!addNodePageModel.isNameValid) {
      bodyTestStyle =
          bodyTestStyle.merge(TextStyle(color: Theme.of(context).cardColor));
    }

    return Scaffold(
      backgroundColor: Theme.of(context).cardColor,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(36),
        child: AppBar(
          automaticallyImplyLeading: false,
          elevation: 0,
          centerTitle: true,
          leading: InkWell(
              onTap: () {
                Navigator.pop(context);
              },
              child: Container(
                width: 64,
                child: Text(tr("team.add_node.cancel")),
                alignment: Alignment.center,
              )),
          backgroundColor: Theme.of(context).canvasColor,
          title: Text(tr("team.add_node.title"),
              style: Theme.of(context)
                  .textTheme
                  .bodyText1!
                  .merge(TextStyle(fontWeight: FontWeight.bold))),
          titleSpacing: 0.0,
          actions: [
            InkWell(
                onTap: addNodePageModel.isNameValid
                    ? addNodePageModel.onTapCreateNode
                    : null,
                child: Container(
                  width: 64,
                  child: Text(
                    tr("team.add_node.confirm"),
                    style: bodyTestStyle,
                  ),
                  alignment: Alignment.center,
                )),
          ],
        ),
      ),
      body: Container(
        child: BouncingScrollView(
          scrollBar: true,
          slivers: [
            SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
                return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 15,
                      ),
                      Container(
                          padding:
                              EdgeInsets.symmetric(vertical: 6, horizontal: 10),
                          child: Text(
                            tr("team.add_node.name"),
                            style: Theme.of(context).textTheme.bodyText1,
                          )),
                      TextField(
                        style: Theme.of(context).textTheme.bodyText1,
                        inputFormatters: [
                          FilteringTextInputFormatter.deny(
                              RegExp(r"[/:;$@#%^*+=\|~]")),
                        ],
                        autofocus: true,
                        onChanged: addNodePageModel.onTextFieldChanged,
                        controller: addNodePageModel.controller,
                        textInputAction: TextInputAction.done,
                        keyboardType: TextInputType.text,
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.symmetric(
                              vertical: 10, horizontal: 10),
                          fillColor: Theme.of(context).canvasColor,
                          filled: true,
                          border: InputBorder.none,
                          suffix: InkWell(
                            onTap: () {
                              addNodePageModel.controller.clear();
                            },
                            child: Container(
                              padding: EdgeInsets.only(right: 8),
                              child: Icon(CupertinoIcons.clear_circled,
                                  size: 16, color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                    ]);
              }, childCount: 1),
            ),
            SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
                return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 15,
                      ),
                      Container(
                          padding:
                              EdgeInsets.symmetric(vertical: 6, horizontal: 10),
                          child: Text(
                            tr("team.add_node.type"),
                            style: Theme.of(context).textTheme.bodyText1,
                          ))
                    ]);
              }, childCount: 1),
            ),
            SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
                NodeType nodeType = NodeType.values[index];
                return RadioListTile<NodeType>(
                  title: Row(children: [
                    Expanded(
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                          Text(
                            tr("team.add_node.type." +
                                EnumToString.convertToString(nodeType)),
                            style: Theme.of(context).textTheme.bodyText1,
                          ),
                          Text(
                            tr("team.add_node.type." +
                                EnumToString.convertToString(nodeType) +
                                ".description"),
                            style: Theme.of(context).textTheme.caption,
                          ),
                        ])),
                    Icon(IconMap.nodeType[nodeType], size: 16)
                  ]),
                  tileColor: Theme.of(context).canvasColor,
                  value: nodeType,
                  groupValue: addNodePageModel.nodeType,
                  onChanged: addNodePageModel.onRadioChanged,
                );
              }, childCount: NodeType.values.length),
            )
          ],
        ),
      ),
    );
  }
}
