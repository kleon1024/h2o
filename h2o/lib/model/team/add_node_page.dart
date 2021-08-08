import 'package:enum_to_string/enum_to_string.dart';
import 'package:flutter/cupertino.dart';
import 'package:h2o/bean/node.dart';
import 'package:h2o/bean/team.dart';
import 'package:h2o/dao/node.dart';
import 'package:h2o/dao/transaction.dart';
import 'package:h2o/model/global.dart';
import 'package:uuid/uuid.dart';

enum IndentType {
  same,
  increase,
}

class AddNodePageModel extends ChangeNotifier {
  BuildContext context;
  GlobalModel globalModel;

  TeamBean team;
  String preNodeID;
  int indent;
  bool showIndentRadio;
  int insertIndex;

  AddNodePageModel(this.team, this.preNodeID, this.indent, this.showIndentRadio,
      this.insertIndex, this.context, this.globalModel);

  TextEditingController controller = TextEditingController();
  NodeType nodeType = NodeType.directory;
  bool isNameValid = false;
  IndentType indentType = IndentType.same;

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
    String uuidString = Uuid().v4();
    NodeBean? nodeBean = NodeBean(
        uuid: uuidString,
        type: EnumToString.convertToString(nodeType),
        name: controller.text,
        indent: indent,
        previousId: preNodeID);
    debugPrint(this.globalModel.nodeDao!.nodeMap.toString());
    this.globalModel.nodeDao!.nodeMap[team.id]!.insert(insertIndex, nodeBean);
    this.globalModel.transactionDao!.transaction(
        Transaction([Operation(OperationType.InsertNode, node: nodeBean)]));

    Navigator.pop(this.context);
    notifyListeners();

    // nodeBean = await Api.createTeamNode(
    //   team.id,
    //   data: {
    //     "id": uuidString,
    //     "name": controller.text,
    //     "type": EnumToString.convertToString(nodeType),
    //     "indent": indent,
    //     "preNodeID": preNodeID,
    //   },
    //   options: this.globalModel.userDao!.accessTokenOptions(),
    // );
    this.globalModel.triggerCallback(EventType.NODE_CREATED);
  }
}
