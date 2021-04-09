import 'package:flutter/cupertino.dart';

class NavigationPageModel extends ChangeNotifier {
  BuildContext? context;

  int currentTeamIndex = 0;

  setContext(BuildContext context) {
    if (this.context == null) {
      this.context = context;
    }
  }
}
