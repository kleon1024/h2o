import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:h2o/bean/block.dart';
import 'package:h2o/model/document/document_page.dart';
import 'package:provider/provider.dart';

class BulletedListBlock extends StatelessWidget {
  final BlockBean block;
  final bool editing;

  const BulletedListBlock(this.block, {this.editing = false});

  @override
  Widget build(BuildContext context) {
    TextStyle textStyle = Theme.of(context).textTheme.bodyText1!;
    Widget widget = Container(
        padding: EdgeInsets.symmetric(vertical: 2, horizontal: 4),
        child: Text(
          this.block.text,
          textAlign: TextAlign.left,
          style: textStyle,
        ));
    if (this.editing) {
      final documentPageModel = Provider.of<DocumentPageModel>(context);
      widget = RawKeyboardListener(
        focusNode: FocusNode(),
        onKey: documentPageModel.handleRawKeyEvent,
        child: TextField(
          focusNode: documentPageModel.focusMap[block.uuid]![block.type],
          style: textStyle,
          keyboardType: TextInputType.multiline,
          maxLines: 2,
          minLines: 1,
          onSubmitted: (_) {
            documentPageModel.onSubmitCreateBlock();
          },
          controller: documentPageModel.editingController,
          onChanged: documentPageModel.onTextFieldChanged,
          decoration: InputDecoration(
            border: InputBorder.none,
            isDense: true,
            hintText: tr("doc.block." + block.type + ".hint"),
            fillColor: Theme.of(context).cardColor,
            filled: true,
            contentPadding: EdgeInsets.symmetric(vertical: 6, horizontal: 4),
          ),
        ),
      );
    }

    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Container(
          padding: EdgeInsets.symmetric(vertical: 6, horizontal: 4),
          child: Text("\u2022  ",
              textAlign: TextAlign.center,
              style: textStyle.merge(TextStyle(fontWeight: FontWeight.bold)))),
      Expanded(child: widget),
    ]);
  }
}
