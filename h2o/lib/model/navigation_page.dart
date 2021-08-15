import 'package:flutter/cupertino.dart';
import 'package:h2o/bean/node.dart';
import 'package:h2o/bean/team.dart';
import 'package:h2o/dao/transaction.dart';
import 'package:h2o/model/global.dart';

class NavigationPageModel extends ChangeNotifier {
  BuildContext? context;
  GlobalModel? globalModel;

  int currentTeamIndex = 0;
  bool lastNodeExpandState = false;

  setContext(BuildContext context, GlobalModel globalModel) {
    if (this.context == null) {
      this.context = context;
      this.globalModel = globalModel;
      globalModel.navigationPageModel = this;
      this.globalModel!.registerCallback(EventType.NODE_CREATED, refresh);
    }
  }

  List<NodeBean> get expandedNodes => () {
        TeamBean team = this.globalModel!.teamDao!.teams[currentTeamIndex];
        List<NodeBean> nodes = [];
        if (this.globalModel!.nodeDao!.nodeMap.containsKey(team.uuid)) {
          var rawNodes = this.globalModel!.nodeDao!.nodeMap[team.uuid]!;
          if (rawNodes.length == 0) {
            return nodes;
          }
          for (int i = 0; i < rawNodes.length - 1; i++) {
            rawNodes[i].isLeaf = (rawNodes[i].indent >= rawNodes[i + 1].indent);
          }
          rawNodes.last.isLeaf = true;
          List<NodeBean> expandStack = [];
          expandStack.add(rawNodes[0]);
          for (int i = 0; i < rawNodes.length; i++) {
            NodeBean n = rawNodes[i];
            if (n.indent > expandStack.last.indent) {
              if (expandStack.last.expanded) {
                nodes.add(n);
                expandStack.add(n);
              }
            } else if (n.indent == expandStack.last.indent) {
              nodes.add(n);
              expandStack.removeLast();
              expandStack.add(n);
            } else {
              expandStack.removeLast();
              i--;
            }
          }
        }
        return nodes;
      }();

  Future refresh() async {
    notifyListeners();
  }

  onReorder(int oldIndex, int newIndex) {
    // TODO: move multiple nodes
    debugPrint("move " + oldIndex.toString() + "->" + newIndex.toString());
    if (oldIndex == newIndex) return;
    TeamBean team = this.globalModel!.teamDao!.teams[currentTeamIndex];
    List<NodeBean> nodes = this.globalModel!.nodeDao!.nodeMap[team.uuid]!;
    NodeBean movingNode = nodes[oldIndex];
    String oldPreviousId = movingNode.previousId;

    List<Operation> ops = [];
    // Remove at oldIndex
    if (oldIndex < nodes.length - 1) {
      nodes[oldIndex + 1].previousId = movingNode.previousId;
    }

    // Insert at newIndex
    if (oldIndex < newIndex) {
      movingNode.previousId = nodes[newIndex].uuid;
      if (newIndex < nodes.length - 1) {
        nodes[newIndex + 1].previousId = movingNode.uuid;
      }
    } else {
      movingNode.previousId = nodes[newIndex].previousId;
      nodes[newIndex].previousId = movingNode.uuid;
    }

    String newPreviousId = movingNode.previousId;

    NodeBean nodeBean = nodes.removeAt(oldIndex);
    nodeBean.previousId = oldPreviousId;
    ops.add(Operation(OperationType.DeleteNode,
        node: NodeBean.fromJson(nodeBean.toJson())));
    nodeBean.previousId = newPreviousId;
    nodes.insert(newIndex, nodeBean);
    ops.add(Operation(OperationType.InsertNode,
        node: NodeBean.fromJson(nodeBean.toJson())));

    this.globalModel!.transactionDao!.transaction(Transaction(ops));

    notifyListeners();
  }

  onExpandNode(NodeBean node, {bool? value}) {
    TeamBean team = this.globalModel!.teamDao!.teams[currentTeamIndex];
    List<NodeBean> nodes = this.globalModel!.nodeDao!.nodeMap[team.uuid]!;
    for (int i = 0; i < nodes.length; i++) {
      if (nodes[i].uuid == node.uuid) {
        if (value == null) {
          nodes[i].expanded = !nodes[i].expanded;
        } else {
          nodes[i].expanded = value;
        }
        break;
      }
    }
    notifyListeners();
  }

  onReorderStart(NodeBean node) {
    TeamBean team = this.globalModel!.teamDao!.teams[currentTeamIndex];
    List<NodeBean> nodes = this.globalModel!.nodeDao!.nodeMap[team.uuid]!;
    for (int i = 0; i < nodes.length; i++) {
      if (nodes[i].uuid == node.uuid) {
        lastNodeExpandState = nodes[i].expanded;
        nodes[i].expanded = false;
        break;
      }
    }
    notifyListeners();
  }

  onReorderEnd(NodeBean node) {
    TeamBean team = this.globalModel!.teamDao!.teams[currentTeamIndex];
    List<NodeBean> nodes = this.globalModel!.nodeDao!.nodeMap[team.uuid]!;
    for (int i = 0; i < nodes.length; i++) {
      if (nodes[i].uuid == node.uuid) {
        nodes[i].expanded = lastNodeExpandState;
        break;
      }
    }
    notifyListeners();
  }

  onTapTeamIcon(int index) {
    this.currentTeamIndex = index;
    notifyListeners();
    this.globalModel!.triggerCallback(EventType.TEAM_SIDEBAR_INDEX_CHANGED);
  }
}
