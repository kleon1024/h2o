import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class BouncingScrollView extends StatelessWidget {
  final List<Widget> slivers;
  final bool scrollBar;

  BouncingScrollView({
    this.slivers = const <Widget>[],
    this.scrollBar = false,
  });

  @override
  Widget build(BuildContext context) {
    var scrollView = CustomScrollView(
        physics: BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
        slivers: this.slivers);

    if (this.scrollBar) {
      return CupertinoScrollbar(child: scrollView);
    }
    return scrollView;
  }
}
