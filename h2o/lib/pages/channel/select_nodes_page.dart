import 'package:easy_localization/easy_localization.dart';
import 'package:enum_to_string/enum_to_string.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:h2o/bean/node.dart';
import 'package:h2o/components/scroll/bouncing_scroll_view.dart';
import 'package:h2o/dao/node.dart';
import 'package:h2o/global/icons.dart';
import 'package:h2o/model/channel/select_nodes_page.dart';
import 'package:h2o/pages/unified_page.dart';
import 'package:provider/provider.dart';

class SelectNodesPage extends StatelessWidget {
  final Function()? onCancel;
  final Function(NodeBean node)? onConfirm;

  SelectNodesPage({
    required this.onCancel,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    final selectNodesPageModel = Provider.of<SelectNodesPageModel>(context);

    List<NodeBean> nodes = selectNodesPageModel.nodes;
    return UnifiedPage(
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(36),
          child: AppBar(
            elevation: 0,
            backgroundColor: Colors.transparent,
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
            centerTitle: true,
            title: Text(
              tr("channel.forward_to_doc.select_doc"),
              style: Theme.of(context)
                  .textTheme
                  .bodyText1!
                  .merge(TextStyle(fontWeight: FontWeight.bold)),
              overflow: TextOverflow.ellipsis,
            ),
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
                              vertical: 8,
                              horizontal: 10,
                            ),
                            child: Row(
                              children: [
                                Icon(iconData),
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
                                                  .bodyText1),
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
                                                .bodyText1),
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                      ),
                                      TextButton(
                                        child: Text(
                                            tr(
                                                "channel.forward_to_doc.confirm"),
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyText1),
                                        onPressed: () {
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
      ),
    );
  }
}
