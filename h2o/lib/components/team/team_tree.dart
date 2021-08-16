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
import 'package:h2o/model/global.dart';
import 'package:h2o/model/navigation_page.dart';
import 'package:h2o/model/team/add_node_page.dart';
import 'package:h2o/pages/team/add_node_page.dart';
import 'package:provider/provider.dart';
import 'package:reorderables/reorderables.dart';

class TeamTree extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final teamDao = Provider.of<TeamDao>(context);
    final nodeDao = Provider.of<NodeDao>(context);
    final navigationPageModel = Provider.of<NavigationPageModel>(context);
    final globalModel = Provider.of<GlobalModel>(context);

    if (teamDao.teams.length == 0) {
      return Container();
    }
    TeamBean team = teamDao.teams[navigationPageModel.currentTeamIndex];

    List<NodeBean> nodes = navigationPageModel.expandedNodes;

    return Container(
      padding: EdgeInsets.symmetric(vertical: 0, horizontal: 8),
      margin: EdgeInsets.symmetric(vertical: 20, horizontal: 8),
      decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.all(Radius.circular(8))),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(40),
          child: AppBar(
            primary: false,
            elevation: 0,
            backgroundColor: Colors.transparent,
            title: Text("Test"),
          ),
        ),
        body: BouncingScrollView(
          controller: ScrollController(),
          slivers: [
            ReorderableSliverList(
                onReorderStarted: (int index) {
                  navigationPageModel.onReorderStart(nodes[index]);
                },
                onReorder: navigationPageModel.onReorder,
                delegate:
                    ReorderableSliverChildBuilderDelegate((context, index) {
                  return Node(
                    nodes[index],
                    onTapExpand: () {
                      nodeDao.loadChildren(nodes[index]);
                      navigationPageModel.onExpandNode(nodes[index]);
                    },
                    onTapPlus: () {
                      Navigator.of(context).push(
                        CupertinoPageRoute(builder: (ctx) {
                          return ChangeNotifierProvider(
                              create: (_) => AddNodePageModel(
                                  team,
                                  nodes[index],
                                  true,
                                  index + 1,
                                  context,
                                  globalModel),
                              child: AddNodePage());
                        }),
                      );
                    },
                  );
                }, childCount: nodes.length)),
            SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
              NodeBean preNode = NodeBean(
                uuid: EMPTY_UUID,
                previousId: EMPTY_UUID,
                parentId: EMPTY_UUID,
                indent: 0,
                name: "virtual-node",
                teamId: team.uuid,
                type: "virtual-node",
              );
              if (nodes.length > 0) {
                preNode = nodes.last;
              }

              return ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).push(
                    CupertinoPageRoute(builder: (ctx) {
                      return ChangeNotifierProvider(
                          create: (_) => AddNodePageModel(team, preNode, false,
                              nodes.length, context, globalModel),
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
