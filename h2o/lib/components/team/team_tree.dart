import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:h2o/bean/team.dart';
import 'package:h2o/components/nodes/node.dart';
import 'package:h2o/components/scroll/bouncing_scroll_view.dart';
import 'package:h2o/dao/user.dart';
import 'package:h2o/global/enum.dart';
import 'package:h2o/model/navigation_page.dart';
import 'package:provider/provider.dart';

class TeamTree extends StatelessWidget {
  final nodes = [
    NodeType.Directory,
    NodeType.TextChannel,
    NodeType.Document,
    NodeType.Table,
  ];

  @override
  Widget build(BuildContext context) {
    final userDao = Provider.of<UserDao>(context);
    final navigationPageModel = Provider.of<NavigationPageModel>(context);

    TeamBean? team;
    if (userDao.user != null &&
        userDao.user!.teams != null &&
        userDao.user!.teams!.length > 0) {
      team = userDao.user!.teams![navigationPageModel.currentTeamIndex];
    }

    return Container(
      padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      margin: EdgeInsets.symmetric(vertical: 18, horizontal: 8),
      decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.all(Radius.circular(8))),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.transparent,
          title: Text(team == null ? "" : team.name),
          titleSpacing: 0.0,
        ),
        body: BouncingScrollView(
          slivers: [
            SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
              return Node(type: nodes[index]);
            }, childCount: nodes.length))
          ],
        ),
      ),
    );
  }
}
