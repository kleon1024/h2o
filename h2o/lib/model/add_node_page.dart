import 'package:enum_to_string/enum_to_string.dart';
import 'package:flutter/cupertino.dart';
import 'package:h2o/api/api.dart';
import 'package:h2o/bean/node.dart';
import 'package:h2o/bean/team.dart';
import 'package:h2o/dao/node.dart';
import 'package:h2o/model/global.dart';

enum IndentType {
  same,
  increase,
}

class AddNodePageModel extends ChangeNotifier {
  BuildContext? context;
  GlobalModel? globalModel;

  TeamBean team;
  String preNodeID;
  String posNodeID;
  int indent;
  bool showIndentRadio;

  AddNodePageModel(this.team, this.preNodeID, this.posNodeID, this.indent,
      this.showIndentRadio);

  TextEditingController controller = TextEditingController();
  NodeType nodeType = NodeType.directory;
  bool isNameValid = false;
  IndentType indentType = IndentType.same;

  setContext(BuildContext context, globalModel) {
    if (this.context == null) {
      this.context = context;
      this.globalModel = globalModel;
    }
  }

  onNodeTypeRadioChanged(NodeType? value) {
    this.nodeType = value!;
    notifyListeners();
  }

  onIndentTypeRadioChanged(IndentType? value) {
    this.indentType = value!;
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
    if (this.indentType == IndentType.increase) {
      indent += 1;
    }
    NodeBean? nodeBean = await Api.createTeamNode(
      team.id,
      data: {
        "name": controller.text,
        "type": EnumToString.convertToString(nodeType),
        "indent": indent,
        "preNodeID": preNodeID,
        "posNodeID": posNodeID,
      },
      options: this.globalModel!.userDao!.accessTokenOptions(),
    );
    if (nodeBean != null) {
      this.globalModel!.triggerCallback(EventType.NODE_CREATED);
      Navigator.pop(this.context!);
    }
  }
}
