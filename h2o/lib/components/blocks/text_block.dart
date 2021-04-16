import 'package:easy_localization/easy_localization.dart';
import 'package:enum_to_string/enum_to_string.dart';
import 'package:flutter/material.dart';
import 'package:h2o/bean/block.dart';
import 'package:h2o/dao/block.dart';
import 'package:h2o/model/document/document_page.dart';
import 'package:provider/provider.dart';

class TextBlock extends StatelessWidget {
  final BlockBean block;
  final bool editing;

  const TextBlock(this.block, {this.editing = false});

  @override
  Widget build(BuildContext context) {
    var textStyle = Theme.of(context).textTheme.bodyText2!;
    var hint = "doc.block." + block.type + ".hint";
    switch (EnumToString.fromString(BlockType.values, block.type)) {
      case BlockType.heading1:
        textStyle = Theme.of(context)
            .textTheme
            .headline6!
            .merge(TextStyle(fontSize: 18, fontWeight: FontWeight.bold));
        break;
      case BlockType.heading2:
        textStyle = Theme.of(context)
            .textTheme
            .headline6!
            .merge(TextStyle(fontSize: 16, fontWeight: FontWeight.bold));
        break;
      case BlockType.heading3:
        textStyle = Theme.of(context)
            .textTheme
            .headline6!
            .merge(TextStyle(fontSize: 13, fontWeight: FontWeight.bold));
        break;
      default:
        textStyle = Theme.of(context).textTheme.bodyText1!;
    }

    if (this.editing) {
      final documentPageModel = Provider.of<DocumentPageModel>(context);
      return RawKeyboardListener(
        focusNode: FocusNode(),
        onKey: documentPageModel.handleRawKeyEvent,
        child: TextField(
          focusNode: documentPageModel.focusMap[block.id]![block.type],
          style: textStyle,
          onSubmitted: (_) {
            documentPageModel.onSubmitCreateBlock(block);
          },
          controller: documentPageModel.editingController,
          onChanged: documentPageModel.onTextFieldChanged,
          decoration: InputDecoration(
            border: InputBorder.none,
            isDense: true,
            hintText: tr(hint),
            fillColor: Theme.of(context).cardColor,
            filled: true,
            contentPadding: EdgeInsets.symmetric(vertical: 6, horizontal: 4),
          ),
        ),
      );
    }

    return Container(
        padding: EdgeInsets.symmetric(vertical: 2, horizontal: 4),
        child: Text(
          this.block.text,
          textAlign: TextAlign.left,
          style: textStyle,
        ));
  }
}
