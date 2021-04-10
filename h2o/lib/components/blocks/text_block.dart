import 'package:flutter/material.dart';
import 'package:h2o/bean/block.dart';

class TextBlock extends StatelessWidget {
  final BlockBean block;
  final bool editing;

  const TextBlock(this.block, {this.editing = false});

  @override
  Widget build(BuildContext context) {
    if (this.editing) {
      final TextEditingController editingController =
          TextEditingController(text: this.block.text);
      return TextField(
        style: TextStyle(
          fontSize: 14,
        ),
        controller: editingController,
        decoration: InputDecoration(border: InputBorder.none, isDense: true),
      );
    }

    return Text(
      this.block.text,
      textAlign: TextAlign.left,
      style: TextStyle(fontSize: 14, height: 1.5),
    );
  }
}
