import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:h2o/components/team/team_sidebar.dart';
import 'package:h2o/components/team/team_tree.dart';
import 'package:h2o/dao/user.dart';
import 'package:provider/provider.dart';

class NavigationPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final userDao = Provider.of<UserDao>(context);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
      ),
      child: Scaffold(
        body: Row(
          children: [
            Expanded(flex: 1, child: TeamSideBar()),
            Expanded(flex: 8, child: TeamTree()),
          ],
        ),
      ),
    );
  }
}
