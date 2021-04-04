import 'package:flutter/material.dart';

class Cell extends StatefulWidget {
  final Widget child;

  const Cell({required this.child});

  @override
  State<StatefulWidget> createState() => CellState();
}

class CellState extends State<Cell> {
  bool isHovering = false;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      hoverColor: Theme.of(context).hoverColor,
      onTap: () {},
      onHover: (isHovering) {
        setState(() {
          this.isHovering = isHovering;
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 2, horizontal: 2),
        child: widget.child,
      ),
    );
  }
}
