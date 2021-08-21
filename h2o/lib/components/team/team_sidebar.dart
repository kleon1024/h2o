import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:h2o/bean/team.dart';
import 'package:h2o/components/scroll/bouncing_scroll_view.dart';
import 'package:h2o/dao/team.dart';
import 'package:h2o/model/navigation_page.dart';
import 'package:provider/provider.dart';

class TeamSideBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final teamDao = Provider.of<TeamDao>(context);
    final navigationPageModel = Provider.of<NavigationPageModel>(context);

    List<TeamBean> teams = teamDao.teams;

    return BouncingScrollView(
      slivers: [
        SliverList(
            delegate: SliverChildBuilderDelegate((context, index) {
          return Container(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: InkWell(
                  onTap: () {
                    navigationPageModel.onTapTeamIcon(index);
                  },
                  child: CircleAvatar(
                    child: Text(teams[index].name[0].toUpperCase()),
                  )));
        }, childCount: teams.length)),
        SliverList(
            delegate: SliverChildBuilderDelegate((context, index) {
          return Container(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: InkWell(
              onTap: () {},
              child: CircleAvatar(
                child: Icon(CupertinoIcons.plus),
              ),
            ),
          );
        }, childCount: 1))
      ],
    );
  }
}
