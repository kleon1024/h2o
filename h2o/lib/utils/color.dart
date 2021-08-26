import 'package:flutter/cupertino.dart';

class ColorUtil {
  static Color ColorFromInt(int color) {
    int b = color % 256;
    int g = (color >> 8) % 256;
    int r = (color >> 16) % 256;

    debugPrint(r.toString());
    debugPrint(g.toString());
    debugPrint(b.toString());
    return Color.fromRGBO(r, g, b, 1);
  }

  static int ColorToInt(Color color) {
    debugPrint("ColorToInt");
    debugPrint(color.red.toString());
    debugPrint(color.green.toString());
    debugPrint(color.blue.toString());
    return (color.red << 16) + (color.green << 8) + color.blue;
  }
}
