import 'package:flutter/material.dart';

class BulletedListBlock extends StatefulWidget {
  final String text;
  final bool hoverEffect;

  const BulletedListBlock({this.text = "", this.hoverEffect = false});

  @override
  State<StatefulWidget> createState() => BulletedListBlockState();
}

class BulletedListBlockState extends State<BulletedListBlock> {
  @override
  Widget build(BuildContext context) {
    Widget row = Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(" \u2022   ",
          style: TextStyle(fontWeight: FontWeight.bold, height: 1.5)),
      Expanded(
        child: Text(
          widget.text,
          style: TextStyle(fontSize: 14, height: 1.5),
        ),
      ),
    ]);

    if (widget.hoverEffect) {
      return InkWell(
        hoverColor: Theme.of(context).hoverColor,
        onTap: () {},
        child: row,
      );
    }
    return Container(child: row);
  }
}
