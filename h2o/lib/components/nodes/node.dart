import 'package:enum_to_string/enum_to_string.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:h2o/bean/node.dart';
import 'package:h2o/dao/node.dart';
import 'package:h2o/global/icons.dart';
import 'package:h2o/model/channel/channel_page.dart';
import 'package:h2o/model/document/document_page.dart';
import 'package:h2o/model/table/table_page.dart';
import 'package:h2o/pages/channel/channel_page.dart';
import 'package:h2o/pages/document/document_page.dart';
import 'package:h2o/pages/table/table_page.dart';
import 'package:provider/provider.dart';

class Node extends StatelessWidget {
  final NodeBean nodeBean;
  final Function()? onTapExpand;
  final Function()? onTapPlus;

  const Node(this.nodeBean, {this.onTapExpand, this.onTapPlus});

  @override
  Widget build(BuildContext context) {
    NodeType? type =
        EnumToString.fromString(NodeType.values, this.nodeBean.type);
    if (type == null) {
      return Container();
    }
    Function()? onTapNode;

    IconData iconData = IconMap.nodeType[type]!;

    switch (type) {
      case NodeType.channel:
        onTapNode = () {
          Navigator.of(context).push(
            CupertinoPageRoute(builder: (ctx) {
              return ChangeNotifierProvider(
                  create: (_) => ChannelPageModel(context, nodeBean),
                  child: ChannelPage());
            }),
          );
        };
        break;
      case NodeType.document:
        onTapNode = () {
          Navigator.of(context).push(
            CupertinoPageRoute(builder: (ctx) {
              return ChangeNotifierProvider(
                  create: (_) => DocumentPageModel(context, nodeBean),
                  child: DocumentPage());
            }),
          );
        };
        break;
      case NodeType.table:
        onTapNode = () {
          Navigator.of(context).push(
            CupertinoPageRoute(builder: (ctx) {
              return ChangeNotifierProvider(
                  create: (_) => TablePageModel(context, nodeBean),
                  child: TablePage());
            }),
          );
        };
        break;
      default:
        onTapNode = onTapExpand;
    }

    IconData icon = CupertinoIcons.circle;
    if (!nodeBean.isLeaf) {
      icon = nodeBean.expanded
          ? CupertinoIcons.chevron_down
          : CupertinoIcons.chevron_right;
    }

    return Container(
      padding: EdgeInsets.symmetric(vertical: 5),
      child: Row(children: [
        InkWell(
          onTap: nodeBean.isLeaf ? null : this.onTapExpand,
          child: Container(
            margin: EdgeInsets.only(right: 8, top: 8, bottom: 8),
            child: Icon(icon),
          ),
        ),
        Expanded(
          child: InkWell(
            onTap: onTapNode,
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 4),
              child: Container(
                padding: EdgeInsets.only(left: 12.0 * nodeBean.indent + 8),
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Icon(iconData),
                      Text(" "),
                      Text(
                        nodeBean.name,
                        style: Theme.of(context).textTheme.bodyText1,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        InkWell(
          onTap: this.onTapPlus,
          child: Container(
            padding: EdgeInsets.only(left: 8, top: 8, bottom: 8),
            child: Icon(CupertinoIcons.plus),
          ),
        ),
      ]),
    );
  }
}
