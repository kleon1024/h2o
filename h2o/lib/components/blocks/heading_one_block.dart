import 'package:flutter/material.dart';

class HeadingOneBlock extends StatelessWidget {
  final String text;

  const HeadingOneBlock({this.text = ""});

  @override
  Widget build(BuildContext context) {
    return Container(child: Text(this.text, style: TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.bold,
    )));
  }
}
