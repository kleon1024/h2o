import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:h2o/components/team/team_sidebar.dart';
import 'package:h2o/components/team/team_tree.dart';

class NavigationPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          Expanded(flex: 1, child: TeamSideBar()),
          Expanded(flex: 8, child: TeamTree()),
        ],
      ),
    );
  }
}
