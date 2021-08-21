import 'package:flutter/material.dart';

class TooltipButton extends StatelessWidget {
  final IconData? icon;
  final String? text;
  final Function()? onTap;

  TooltipButton({
    this.icon,
    this.text,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    List<Widget> widgets = [];
    if (this.icon != null) {
      widgets.add(Icon(this.icon));
    }

    if (this.text != null) {
      widgets.add(Text(
        this.text!,
        style: Theme.of(context).textTheme.bodyText1,
        overflow: TextOverflow.ellipsis,
      ));
    }

    return GestureDetector(
      onTap: this.onTap,
      child: Container(
        width: 60,
        // color: Colors.blue,
        margin: EdgeInsets.symmetric(vertical: 6, horizontal: 10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: widgets,
        ),
      ),
    );
  }
}
