import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:h2o/bean/node.dart';
import 'package:h2o/bean/team.dart';
import 'package:h2o/components/nodes/node.dart';
import 'package:h2o/components/scroll/bouncing_scroll_view.dart';
import 'package:h2o/dao/node.dart';
import 'package:h2o/dao/team.dart';
import 'package:h2o/global/constants.dart';
import 'package:h2o/model/navigation_page.dart';
import 'package:h2o/pages/team/add_node_page.dart';
import 'package:provider/provider.dart';

import '../../model/team/add_node_page.dart';

class TeamTree extends StatefulWidget {
  @override
  createState() => TeamTreeState();
}

class TeamTreeState extends State<TeamTree> {
  @override
  Widget build(BuildContext context) {
    final teamDao = Provider.of<TeamDao>(context);
    final nodeDao = Provider.of<NodeDao>(context);
    final navigationPageModel = Provider.of<NavigationPageModel>(context);

    TeamBean? team;
    if (teamDao.teams.length > 0) {
      team = teamDao.teams[navigationPageModel.currentTeamIndex];
    }

    List<NodeBean> nodes = [];
    if (team != null && nodeDao.nodeMap.containsKey(team.id)) {
      nodes = nodeDao.nodeMap[team.id]!;
    }

    return Container(
      padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      margin: EdgeInsets.symmetric(vertical: 18, horizontal: 8),
      decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.all(Radius.circular(8))),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(36),
          child: AppBar(
            elevation: 0,
            backgroundColor: Colors.transparent,
            title: Text(team == null ? "" : team.name),
            titleSpacing: 0.0,
          ),
        ),
        body: BouncingScrollView(
          slivers: [
            SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
              return Node(nodes[index], onTapPlus: () {
                var preNodeID = nodes[index].id;
                var posNodeID = EMPTY_UUID;
                if (index < nodes.length - 1) {
                  posNodeID = nodes[index + 1].id;
                }

                Navigator.of(context).push(
                  CupertinoPageRoute(builder: (ctx) {
                    return ChangeNotifierProvider(
                        create: (_) => AddNodePageModel(team!, preNodeID,
                            posNodeID, nodes[index].indent, true, index),
                        child: AddNodePage());
                  }),
                );
              });
            }, childCount: nodes.length)),
            SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
              String preNodeID = EMPTY_UUID;
              String posNodeID = EMPTY_UUID;
              int indent = 0;
              if (nodes.length > 0) {
                preNodeID = nodes[nodes.length - 1].id;
              }

              return ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).push(
                    CupertinoPageRoute(builder: (ctx) {
                      return ChangeNotifierProvider(
                          create: (_) => AddNodePageModel(team!, preNodeID,
                              posNodeID, indent, false, nodes.length),
                          child: AddNodePage());
                    }),
                  );
                },
                icon: Icon(CupertinoIcons.plus),
                label: Text(tr("team.add_node")),
              );
            }, childCount: 1)),
          ],
        ),
      ),
    );
  }
}
