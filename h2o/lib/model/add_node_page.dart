import 'package:enum_to_string/enum_to_string.dart';
import 'package:flutter/cupertino.dart';
import 'package:h2o/api/api.dart';
import 'package:h2o/bean/node.dart';
import 'package:h2o/bean/team.dart';
import 'package:h2o/dao/node.dart';
import 'package:h2o/model/global.dart';

class AddNodePageModel extends ChangeNotifier {
  BuildContext? context;
  GlobalModel? globalModel;

  TeamBean team;

  AddNodePageModel(this.team);

  TextEditingController controller = TextEditingController();
  NodeType nodeType = NodeType.directory;
  bool isNameValid = false;

  setContext(BuildContext context, globalModel) {
    if (this.context == null) {
      this.context = context;
      this.globalModel = globalModel;
    }
  }

  onRadioChanged(NodeType? value) {
    this.nodeType = value!;
    notifyListeners();
  }

  onTextFieldChanged(String text) {
    text = text.trimLeft();
    if (text.endsWith(" ")) {
      text = text.substring(0, text.length - 1) + "-";
    }
    text = text.replaceAll(" ", "");
    isNameValid = text.isNotEmpty;
    controller.text = text;
    controller.selection = TextSelection.fromPosition(
        TextPosition(offset: controller.text.length));
    notifyListeners();
  }

  onTapCreateNode() async {
    NodeBean? nodeBean = await Api.createTeamNode(
      team.id,
      data: {
        "name": controller.text,
        "type": EnumToString.convertToString(nodeType)
      },
      options: this.globalModel!.userDao!.accessTokenOptions(),
    );
    if (nodeBean != null) {
      this.globalModel!.triggerCallback(EventType.NODE_CREATED);
      Navigator.pop(this.context!);
    }
  }
}
