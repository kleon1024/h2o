import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class BouncingScrollView extends StatelessWidget {
  final List<Widget> slivers;
  final bool scrollBar;
  final bool reverse;
  ScrollController? controller;

  BouncingScrollView({
    this.slivers = const <Widget>[],
    this.scrollBar = false,
    this.reverse = false,
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    var scrollView = CustomScrollView(
        controller: controller,
        physics: BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
        reverse: this.reverse,
        slivers: this.slivers);

    if (this.scrollBar) {
      return CupertinoScrollbar(child: scrollView);
    }
    return scrollView;
  }
}
