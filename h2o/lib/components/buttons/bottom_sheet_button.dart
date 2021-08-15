import 'package:flutter/material.dart';

class BottomSheetButton extends StatelessWidget {
  final IconData? icon;
  final String? text;
  final Function()? onTap;

  BottomSheetButton({
    this.icon,
    this.text,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    List<Widget> widgets = [];
    if (this.icon != null) {
      widgets.add(Icon(this.icon, size: 16));
    }
    if (this.text != null) {
      widgets.add(Text(
        this.text!,
        style: Theme.of(context).textTheme.bodyText2,
        overflow: TextOverflow.ellipsis,
      ));
    }

    return GestureDetector(
      onTap: this.onTap,
      child: Container(
        // color: Colors.blue,
        padding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: widgets,
        ),
      ),
    );
  }
}
