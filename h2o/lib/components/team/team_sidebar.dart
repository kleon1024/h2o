import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:h2o/bean/team.dart';
import 'package:h2o/components/scroll/bouncing_scroll_view.dart';
import 'package:h2o/dao/user.dart';
import 'package:h2o/model/navigation_page.dart';
import 'package:provider/provider.dart';

class TeamSideBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final userDao = Provider.of<UserDao>(context);
    final navigationPageModel = Provider.of<NavigationPageModel>(context);

    List<TeamBean> teams = [];
    if (userDao.user != null && userDao.user!.teams != null) {
      teams = userDao.user!.teams!;
    }

    return BouncingScrollView(
      slivers: [
        SliverList(
            delegate: SliverChildBuilderDelegate((context, index) {
          return Container(
              padding:
                  EdgeInsets.only(top: 8 + (index == 0 ? 18 : 0), bottom: 8),
              child: InkWell(
                  onTap: () {
                    navigationPageModel.currentTeamIndex = index;
                  },
                  child: CircleAvatar(
                    child: Text(teams[index].name[0].toUpperCase()),
                  )));
        }, childCount: teams.length)),
        SliverList(
            delegate: SliverChildBuilderDelegate((context, index) {
          return Container(
            padding: EdgeInsets.symmetric(vertical: 18),
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
