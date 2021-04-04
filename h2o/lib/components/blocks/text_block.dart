import 'package:flutter/material.dart';

class TextBlock extends StatelessWidget {
  final String text;
  final bool editing;

  const TextBlock({this.text = "", this.editing = false});

  @override
  Widget build(BuildContext context) {
    if (this.editing) {
      final TextEditingController editingController =
          TextEditingController(text: this.text);
      return TextField(
        style: TextStyle(
          fontSize: 14,
        ),
        controller: editingController,
        decoration: InputDecoration(border: InputBorder.none, isDense: true),
      );
    }

    return Text(
      this.text,
      textAlign: TextAlign.left,
      style: TextStyle(fontSize: 14, height: 1.5),
    );
  }
}
