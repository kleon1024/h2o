import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:h2o/bean/node.dart';
import 'package:h2o/bean/team.dart';
import 'package:h2o/components/nodes/node.dart';
import 'package:h2o/components/scroll/bouncing_scroll_view.dart';
import 'package:h2o/dao/node.dart';
import 'package:h2o/dao/team.dart';
import 'package:h2o/model/add_node_page.dart';
import 'package:h2o/model/navigation_page.dart';
import 'package:h2o/pages/team/add_node_page.dart';
import 'package:provider/provider.dart';

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
              return Node(nodes[index]);
            }, childCount: nodes.length)),
            SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
              return ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).push(
                    CupertinoPageRoute(builder: (ctx) {
                      return ChangeNotifierProvider(
                          create: (_) => AddNodePageModel(team!),
                          child: AddNodePage());
                    }),
                  );
                },
                icon: Icon(CupertinoIcons.add, size: 16),
                label: Text(tr("team.add_node")),
                style: ElevatedButton.styleFrom(
                    primary: Theme.of(context).highlightColor),
              );
            }, childCount: 1)),
          ],
        ),
      ),
    );
  }
}
