import 'package:flutter/material.dart';

class HeadingThreeBlock extends StatelessWidget {
  final String text;

  const HeadingThreeBlock({this.text = ""});

  @override
  Widget build(BuildContext context) {
    return Container(
        child: Text(this.text,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            )));
  }
}
