import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:h2o/bean/node.dart';
import 'package:h2o/bean/team.dart';
import 'package:h2o/components/nodes/node.dart';
import 'package:h2o/components/scroll/bouncing_scroll_view.dart';
import 'package:h2o/components/team/team_sidebar.dart';
import 'package:h2o/dao/node.dart';
import 'package:h2o/dao/team.dart';
import 'package:h2o/dao/user.dart';
import 'package:h2o/global/constants.dart';
import 'package:h2o/model/global.dart';
import 'package:h2o/model/navigation_page.dart';
import 'package:h2o/model/team/add_node_page.dart';
import 'package:h2o/pages/team/add_node_page.dart';
import 'package:h2o/pages/unified_page.dart';
import 'package:provider/provider.dart';
import 'package:reorderables/reorderables.dart';

class TeamTree extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final teamDao = Provider.of<TeamDao>(context);
    final nodeDao = Provider.of<NodeDao>(context);
    final navigationPageModel = Provider.of<NavigationPageModel>(context);
    final globalModel = Provider.of<GlobalModel>(context);
    final userDao = Provider.of<UserDao>(context);

    if (teamDao.teams.length == 0) {
      return Container();
    }
    TeamBean team = teamDao.teams[navigationPageModel.currentTeamIndex];

    List<NodeBean> nodes = navigationPageModel.expandedNodes;

    return UnifiedPage(
      child: Scaffold(
        key: navigationPageModel.scaffoldKey,
        drawer: Drawer(
          child: Container(
            child: Row(
              children: [
                Container(
                  width: 60,
                  padding: EdgeInsets.symmetric(horizontal: 3),
                  child: TeamSideBar(),
                ),
                Expanded(
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                    color: Theme.of(context).cardColor,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "username",
                          style: Theme.of(context).textTheme.headline6,
                        )
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(40),
          child: AppBar(
            primary: false,
            elevation: 0,
            centerTitle: false,
            backgroundColor: Colors.transparent,
            title: Text(team.name),
            leading: InkWell(
              onTap: () {
                navigationPageModel.scaffoldKey.currentState!.openDrawer();
              },
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 5),
                child: CircleAvatar(
                  backgroundColor: Theme.of(context).colorScheme.secondary,
                  child: Container(
                      child: Text(
                    "un",
                    style: Theme.of(context).textTheme.caption,
                    overflow: TextOverflow.ellipsis,
                  )),
                ),
              ),
            ),
          ),
        ),
        body: GestureDetector(
          onTap: () {
            FocusScope.of(context).requestFocus(FocusNode());
          },
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 10),
            child: BouncingScrollView(
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
                              create: (_) => AddNodePageModel(team, preNode,
                                  false, nodes.length, context, globalModel),
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
        ),
      ),
    );
  }
}
