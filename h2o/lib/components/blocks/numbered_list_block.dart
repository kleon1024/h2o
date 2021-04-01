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
        child: TextButton(onPressed: () {}, child: Text(this.widget.text)),
      ),
      isHovering
          ? TextButton(onPressed: () {}, child: Text("Editing"))
          : Container(),
    ]));
  }
}
