import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class BasicNode extends StatelessWidget {
  final String name;
  final int indentLevel;
  final IconData icon;
  final Function() onTapNode;
  final Function() onTapPlus;
  final bool expanded;

  const BasicNode({
    required this.name,
    required this.indentLevel,
    required this.icon,
    required this.expanded,
    required this.onTapNode,
    required this.onTapPlus,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Row(children: [
        InkWell(
          onTap: this.onTapPlus,
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 4),
            child: Icon(
                this.expanded
                    ? CupertinoIcons.chevron_down
                    : CupertinoIcons.chevron_right,
                size: 16),
          ),
        ),
        Expanded(
            child: InkWell(
          onTap: this.onTapNode,
          child: Container(
            padding: EdgeInsets.only(left: 12.0 * this.indentLevel),
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Icon(this.icon, size: 16),
                  Text(" "),
                  Text(
                    this.name,
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
          ),
        )),
        InkWell(
          onTap: this.onTapPlus,
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 4),
            child: Icon(CupertinoIcons.plus, size: 16),
          ),
        ),
      ]),
    );
  }
}
