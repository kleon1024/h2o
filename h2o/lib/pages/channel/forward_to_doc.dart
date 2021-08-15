import 'package:easy_localization/easy_localization.dart';
import 'package:enum_to_string/enum_to_string.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:h2o/bean/node.dart';
import 'package:h2o/components/scroll/bouncing_scroll_view.dart';
import 'package:h2o/dao/node.dart';
import 'package:h2o/global/icons.dart';
import 'package:provider/provider.dart';

class ForwardToDocPage extends StatelessWidget {
  final String teamId;
  final Function()? onCancel;
  final Function(NodeBean node)? onConfirm;
  final NodeType type;

  ForwardToDocPage(
      {required this.teamId,
      required this.onCancel,
      required this.onConfirm,
      required this.type});

  @override
  Widget build(BuildContext context) {
    final nodeDao = Provider.of<NodeDao>(context);

    List<NodeBean> nodes = [];
    if (nodeDao.nodeMap.containsKey(this.teamId)) {
      var allNodes = nodeDao.nodeMap[this.teamId]!;
      allNodes.forEach((n) {
        if (EnumToString.fromString(NodeType.values, n.type) == this.type) {
          nodes.add(n);
        }
      });
    }

    return Scaffold(
      backgroundColor: Theme.of(context).cardColor,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(36),
        child: AppBar(
          leading: InkWell(
              child: Center(
                child: Text(tr("channel.block.selection.cancel"),
                    style: Theme.of(context).textTheme.bodyText2,
                    overflow: TextOverflow.ellipsis),
              ),
              onTap: () {
                Navigator.of(context).pop();
                if (this.onCancel != null) {
                  this.onCancel!();
                }
              }),
          title: Text(tr("channel.forward_to_doc.select_doc")),
          actions: [],
        ),
      ),
      body: Column(children: [
        Expanded(
          child: BouncingScrollView(
            scrollBar: true,
            slivers: [
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    IconData iconData = IconMap.nodeType[
                        EnumToString.fromString(
                            NodeType.values, nodes[index].type)]!;

                    return InkWell(
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            vertical: 6,
                            horizontal: 20,
                          ),
                          child: Row(
                            children: [
                              Icon(iconData, size: 16),
                              Text(" "),
                              Text(
                                nodes[index].name,
                                style: Theme.of(context).textTheme.bodyText1,
                              ),
                            ],
                          ),
                        ),
                        onTap: () {
                          showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: Text(
                                      tr("channel.forward_to_doc.copy_to"),
                                      style: Theme.of(context)
                                          .textTheme
                                          .subtitle1),
                                  content: SingleChildScrollView(
                                    child: ListBody(
                                      children: <Widget>[
                                        Text(nodes[index].name,
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyText2),
                                      ],
                                    ),
                                  ),
                                  actionsAlignment:
                                      MainAxisAlignment.spaceAround,
                                  actions: <Widget>[
                                    TextButton(
                                      child: Text(
                                          tr("channel.forward_to_doc.cancel"),
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyText2),
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                    ),
                                    TextButton(
                                      child: Text(
                                          tr("channel.forward_to_doc.confirm"),
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyText2),
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                        Navigator.of(context).pop();
                                        if (this.onConfirm != null) {
                                          this.onConfirm!(nodes[index]);
                                        }
                                      },
                                    ),
                                  ],
                                );
                              });
                        });
                  },
                  childCount: nodes.length,
                ),
              ),
            ],
          ),
        ),
      ]),
    );
  }
}
