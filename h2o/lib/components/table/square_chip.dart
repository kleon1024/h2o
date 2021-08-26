import 'package:flutter/material.dart';

class SquareChip extends StatelessWidget {
  final String text;
  final Color? backgroundColor;
  final VoidCallback? onPressed;

  const SquareChip({required this.text, this.onPressed, this.backgroundColor});

  @override
  Widget build(BuildContext context) {
    return InputChip(
      backgroundColor: backgroundColor,
      label: Text(
        text,
        style: Theme.of(context).textTheme.bodyText2,
      ),
      onPressed: onPressed,
      labelPadding: EdgeInsets.symmetric(vertical: -3, horizontal: 3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(3),
      ),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      padding: EdgeInsets.zero,
      side: BorderSide.none,
    );
  }
}
