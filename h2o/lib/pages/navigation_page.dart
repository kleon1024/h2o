import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:h2o/components/team/team_sidebar.dart';
import 'package:h2o/components/team/team_tree.dart';
import 'package:h2o/model/global.dart';
import 'package:h2o/model/navigation_page.dart';
import 'package:provider/provider.dart';

class NavigationPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final globalModel = Provider.of<GlobalModel>(context);
    final navigationPageModel = Provider.of<NavigationPageModel>(context)
      ..setContext(context, globalModel);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
      ),
      child: Scaffold(
        body: Container(
          padding: EdgeInsets.symmetric(vertical: 0, horizontal: 8),
          child: Row(
            children: [
              Expanded(flex: 1, child: TeamSideBar()),
              Expanded(flex: 8, child: TeamTree()),
            ],
          ),
        ),
      ),
    );
  }
}
