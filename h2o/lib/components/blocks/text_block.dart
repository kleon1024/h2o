import 'package:easy_localization/easy_localization.dart';
import 'package:enum_to_string/enum_to_string.dart';
import 'package:flutter/material.dart';
import 'package:h2o/bean/block.dart';
import 'package:h2o/dao/block.dart';

class TextBlock extends StatelessWidget {
  final BlockBean block;
  final bool editing;
  final Function(RawKeyEvent event)? handleRawKeyEvent;
  final FocusNode? focusNode;
  final Function()? onSubmitCreateBlock;
  final TextEditingController? editingController;
  final Function(String text)? onTextFieldChanged;

  const TextBlock(this.block,
      {this.editing = false,
      this.handleRawKeyEvent,
      this.focusNode,
      this.onTextFieldChanged,
      this.onSubmitCreateBlock,
      this.editingController});

  @override
  Widget build(BuildContext context) {
    var textStyle = Theme.of(context).textTheme.bodyText1;
    var hint = "doc.block." + block.type + ".hint";
    switch (EnumToString.fromString(BlockType.values, block.type)) {
      case BlockType.heading1:
        textStyle = Theme.of(context).textTheme.headline1;
        break;
      case BlockType.heading2:
        textStyle = Theme.of(context).textTheme.headline2;
        break;
      case BlockType.heading3:
        textStyle = Theme.of(context).textTheme.headline3;
        break;
      default:
        textStyle = Theme.of(context).textTheme.bodyText1!;
    }

    if (this.editing) {
      return RawKeyboardListener(
        focusNode: FocusNode(),
        onKey: handleRawKeyEvent,
        child: TextField(
          keyboardType: TextInputType.multiline,
          maxLines: 2,
          minLines: 1,
          focusNode: focusNode,
          style: textStyle,
          onSubmitted: (_) {
            onSubmitCreateBlock!();
          },
          onEditingComplete: () {
            debugPrint("on Editing Complete");
          },
          controller: editingController,
          onChanged: onTextFieldChanged,
          decoration: InputDecoration(
            border: InputBorder.none,
            isDense: true,
            hintText: tr(hint),
            fillColor: Colors.transparent,
            filled: true,
            contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 4),
          ),
        ),
      );
    }

    return Container(
        color: Theme.of(context).canvasColor,
        padding: EdgeInsets.symmetric(vertical: 6, horizontal: 4),
        child: Text(
          this.block.text
          // +
          // " " +
          // block.preBlockID.substring(0, 3) +
          // " " +
          // block.id.substring(0, 3) +
          // " " +
          // block.posBlockID.substring(0, 3)
          ,
          textAlign: TextAlign.left,
          style: textStyle,
        ));
  }
}
