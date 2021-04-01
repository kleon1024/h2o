import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:h2o/components/scroll/bouncing_scroll_view.dart';
import 'package:h2o/pages/channel/channel_page.dart';

class TeamTree extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
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
          title: Text("Yeah My Team"),
          titleSpacing: 0.0,
        ),
        body: BouncingScrollView(
          slivers: [
            SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
              return TextButton(
                onPressed: () {
                  Navigator.of(context).push(CupertinoPageRoute(builder: (ctx) {
                    return ChannelPage();
                  }));
                },
                child: Container(
                  padding: EdgeInsets.only(left: 12.0 * index),
                  child: Row(
                    children: [
                      Icon(CupertinoIcons.number, size: 18),
                      Text("channel"),
                    ],
                  ),
                ),
              );
            }, childCount: 3))
          ],
        ),
      ),
    );
  }
}
