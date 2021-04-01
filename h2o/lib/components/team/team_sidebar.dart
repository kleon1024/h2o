import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:h2o/components/scroll/bouncing_scroll_view.dart';

class TeamSideBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BouncingScrollView(
      slivers: [
        SliverList(
            delegate: SliverChildBuilderDelegate((context, index) {
          return Container(
              padding:
                  EdgeInsets.only(top: 8 + (index == 0 ? 18 : 0), bottom: 8),
              child: CircleAvatar());
        }, childCount: 3))
      ],
    );
  }
}
