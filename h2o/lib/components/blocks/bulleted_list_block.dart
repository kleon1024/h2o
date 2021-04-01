import 'package:flutter/material.dart';

class BulletedListBlock extends StatelessWidget {
  final String text;

  const BulletedListBlock({this.text = ""});

  @override
  Widget build(BuildContext context) {
    return Container(
        child: Row(children: [
      Text(" \u2022   ",
          style: TextStyle(fontWeight: FontWeight.bold)),
      Text(this.text)
    ]));
  }
}
