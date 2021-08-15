import 'package:flutter/material.dart';

class TooltipButton extends StatelessWidget {
  final IconData icon;
  final String? text;
  final Function()? onTap;

  TooltipButton({
    required this.icon,
    this.text,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    List<Widget> widgets = [];
    widgets.add(Icon(this.icon, size: 16));
    if (this.text != null) {
      widgets.add(Text(
        this.text!,
        style: Theme.of(context).textTheme.bodyText2,
      ));
    }

    return GestureDetector(
      onTap: this.onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 6, horizontal: 10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: widgets,
        ),
      ),
    );
  }
}
