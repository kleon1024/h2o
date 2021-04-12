import 'package:flutter/material.dart';
import 'package:h2o/bean/block.dart';
import 'package:h2o/model/document/document_page.dart';
import 'package:provider/provider.dart';

class TextBlock extends StatelessWidget {
  final BlockBean block;
  final bool editing;

  const TextBlock(this.block, {this.editing = false});

  @override
  Widget build(BuildContext context) {
    if (this.editing) {
      final documentPageModel = Provider.of<DocumentPageModel>(context);
      return TextField(
        focusNode: documentPageModel.focusMap[block.id]!,
        style: Theme.of(context).textTheme.bodyText1!,
        onSubmitted: (_) {
          documentPageModel.onSubmitCreateBlock(block);
        },
        controller: documentPageModel.editingController,
        onChanged: documentPageModel.onTextFieldChanged,
        decoration: InputDecoration(
          border: InputBorder.none,
          isDense: true,
          hintText: "command",
          fillColor: Theme.of(context).cardColor,
          filled: true,
          contentPadding: EdgeInsets.symmetric(vertical: 6, horizontal: 4),
        ),
      );
    }

    return Container(
        padding: EdgeInsets.symmetric(vertical: 2, horizontal: 4),
        child: Text(
          this.block.text,
          textAlign: TextAlign.left,
          style: Theme.of(context).textTheme.bodyText1!,
        ));
  }
}
