import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class BouncingScrollView extends StatelessWidget {
  final List<Widget> slivers;
  final bool scrollBar;
  final bool reverse;

  BouncingScrollView({
    this.slivers = const <Widget>[],
    this.scrollBar = false,
    this.reverse = false,
  });

  @override
  Widget build(BuildContext context) {
    var scrollView = CustomScrollView(
        physics: BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
        reverse: this.reverse,
        slivers: this.slivers);

    if (this.scrollBar) {
      return CupertinoScrollbar(child: scrollView);
    }
    return scrollView;
  }
}
