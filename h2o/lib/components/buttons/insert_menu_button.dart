import 'package:flutter/material.dart';

class InsertMenuButton extends StatelessWidget {
  final IconData? icon;
  final String? text;
  final Function()? onTap;

  InsertMenuButton({
    this.icon,
    this.text,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    List<Widget> widgets = [];
    if (this.icon != null) {
      widgets.add(Container(
          width: 40,
          height: 40,
          color: Theme.of(context).cardColor,
          child: Icon(this.icon, size: 16)));
    }

    if (this.text != null) {
      widgets.add(Text(
        this.text!,
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.caption,
      ));
    }

    return GestureDetector(
      onTap: this.onTap,
      child: Container(
        width: 85,
        // color: Colors.blue,
        padding: EdgeInsets.symmetric(vertical: 10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: widgets,
        ),
      ),
    );
  }
}
