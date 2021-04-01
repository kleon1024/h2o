import 'package:flutter/material.dart';

class TextBlock extends StatelessWidget {
  final String text;

  const TextBlock({this.text = ""});

  @override
  Widget build(BuildContext context) {
    return Container(child: Text(this.text));
  }
}
