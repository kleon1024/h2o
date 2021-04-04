import 'package:flutter/material.dart';

class NumberedListBlock extends StatefulWidget {
  final String text;

  const NumberedListBlock({this.text = ""});

  @override
  State<StatefulWidget> createState() => NumberedListBlockState();
}

class NumberedListBlockState extends State<NumberedListBlock> {
  bool isHovering = false;

  @override
  Widget build(BuildContext context) {
    return Container(
        child: Row(children: [
      Text(" 1.  "),
      InkWell(
        onTap: () {},
        onHover: (isHovering) {
          setState(() {
            this.isHovering = isHovering;
          });
        },
        child: Text(widget.text),
      ),
      isHovering ? InkWell(onTap: () {}, child: Text("Editing")) : Container(),
    ]));
  }
}
