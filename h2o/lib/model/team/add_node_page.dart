import 'package:enum_to_string/enum_to_string.dart';
import 'package:flutter/cupertino.dart';
import 'package:h2o/bean/node.dart';
import 'package:h2o/bean/team.dart';
import 'package:h2o/dao/node.dart';
import 'package:h2o/dao/transaction.dart';
import 'package:h2o/global/constants.dart';
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
  NodeBean preNode;
  bool showIndentRadio;
  int insertIndex;

  AddNodePageModel(this.team, this.preNode, this.showIndentRadio,
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
    String parentId = preNode.parentId;
    int indent = preNode.indent;
    String previousId = preNode.uuid;

    if (this.indentType == IndentType.increase) {
      parentId = preNode.uuid;
      indent += 1;
      previousId = EMPTY_UUID;
    }
    var teamNodes = this.globalModel.nodeDao!.nodeMap[team.uuid]!;
    String uuidString = Uuid().v4();
    NodeBean nodeBean = NodeBean(
      uuid: uuidString,
      type: EnumToString.convertToString(nodeType),
      name: controller.text,
      indent: indent,
      parentId: parentId,
      previousId: previousId,
      teamId: team.uuid,
    );

    if (this.indentType == IndentType.increase) {
      if (preNode.children == null) {
        await this.globalModel.nodeDao!.loadChildren(preNode);
      }
      var children = preNode.children!;
      if (children.length > 0) {
        children[0].previousId = nodeBean.uuid;
      }
      nodeBean.parent = preNode;
      children.insert(0, nodeBean);
      preNode.expanded = true;
    } else {
      List<NodeBean> siblings = teamNodes;
      if (preNode.parent != null) {
        siblings = preNode.parent!.children!;
      }
      nodeBean.parent = preNode.parent;

      for (int i = 0; i < siblings.length; i++) {
        if (siblings[i].uuid == preNode.uuid) {
          if (i != siblings.length - 1) {
            siblings[i + 1].previousId = nodeBean.uuid;
          }
          siblings.insert(i + 1, nodeBean);
        }
      }
    }

    List<Operation> ops = [];
    ops.add(Operation(OperationType.InsertNode, node: nodeBean));

    if (nodeType == NodeType.table) {
      this.globalModel.tableDao!.tableColumnMap[nodeBean.uuid] = [];
      this.globalModel.tableDao!.tableRowMap[nodeBean.uuid] = [];
      ops.add(Operation(OperationType.InsertTable, node: nodeBean));
    }
    this.globalModel.transactionDao!.transaction(Transaction(ops));

    Navigator.pop(this.context);
    notifyListeners();
    this.globalModel.triggerCallback(EventType.NODE_CREATED);
  }
}
