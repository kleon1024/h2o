import 'package:flutter/cupertino.dart';
import 'package:h2o/bean/node.dart';
import 'package:h2o/bean/team.dart';
import 'package:h2o/dao/transaction.dart';
import 'package:h2o/global/constants.dart';
import 'package:h2o/model/global.dart';

class NavigationPageModel extends ChangeNotifier {
  BuildContext? context;
  GlobalModel? globalModel;

  int currentTeamIndex = 0;
  bool lastNodeExpandState = false;
  NodeBean? lastNodeReordering;

  setContext(BuildContext context, GlobalModel globalModel) {
    if (this.context == null) {
      this.context = context;
      this.globalModel = globalModel;
      globalModel.navigationPageModel = this;
      this.globalModel!.registerCallback(EventType.NODE_CREATED, refresh);
    }
  }

  List<NodeBean> getChildren(NodeBean node) {
    List<NodeBean> nodes = [];
    if (node.expanded) {
      if (node.children != null) {
        for (var n in node.children!) {
          n.isLeaf = n.children != null && n.children!.length == 0;
          nodes.add(n);
          nodes.addAll(getChildren(n));
        }
      }
    }
    return nodes;
  }

  List<NodeBean> get expandedNodes => () {
        TeamBean team = this.globalModel!.teamDao!.teams[currentTeamIndex];
        List<NodeBean> nodes = [];
        if (this.globalModel!.nodeDao!.nodeMap.containsKey(team.uuid)) {
          var rawNodes = this.globalModel!.nodeDao!.nodeMap[team.uuid]!;
          if (rawNodes.length == 0) {
            return nodes;
          }
          for (var n in rawNodes) {
            n.isLeaf = n.children != null && n.children!.length == 0;
            nodes.add(n);
            if (n.children != null) {
              nodes.addAll(getChildren(n));
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
    List<NodeBean> nodes = this.expandedNodes;
    debugPrint(nodes.toString());
    List<NodeBean> teamNodes = this.globalModel!.nodeDao!.nodeMap[team.uuid]!;
    NodeBean movingNode = nodes[oldIndex];
    debugPrint("movingNode: " + movingNode.uuid);
    debugPrint("movingNode Parent: " + movingNode.parent.toString());
    debugPrint("movingNode Children: " + movingNode.children.toString());
    NodeBean nodeToDelete = NodeBean.fromJson(movingNode.toJson());

    List<Operation> ops = [];
    // Remove at oldIndex
    List<NodeBean> oldSiblings = teamNodes;
    if (movingNode.parent != null) {
      oldSiblings = movingNode.parent!.children!;
    }
    debugPrint(oldSiblings.toString());
    int oldSiblingIndex = oldSiblings.length - 1;
    if (movingNode.uuid != oldSiblings.last.uuid) {
      for (int i = 0; i < oldSiblings.length - 1; i++) {
        if (oldSiblings[i].uuid == movingNode.uuid) {
          oldSiblings[i + 1].previousId = movingNode.previousId;
          oldSiblingIndex = i;
        }
      }
    }

    movingNode = oldSiblings.removeAt(oldSiblingIndex);
    debugPrint("oldSiblingIndex: " + oldSiblingIndex.toString());
    debugPrint("movingNode: " + movingNode.uuid);

    List<NodeBean> newSiblings = teamNodes;
    if (nodes[newIndex].parent != null) {
      newSiblings = nodes[newIndex].parent!.children!;
    }
    int newSiblingIndex = newSiblings.length;
    if (newIndex == 0) {
      newSiblingIndex = 0;
      if (nodes[newIndex].uuid != newSiblings.first.uuid) {
        for (int i = 1; i < newSiblings.length; i++) {
          if (newSiblings[i].uuid == nodes[newIndex].uuid) {
            newSiblingIndex = i;
          }
        }
      }

      movingNode.previousId = nodes[newIndex].previousId;
      movingNode.parentId = nodes[newIndex].parentId;
      movingNode.parent = nodes[newIndex].parent;
      movingNode.indent = nodes[newIndex].indent;
      nodes[newIndex].previousId = movingNode.uuid;
    } else {
      if (oldIndex > newIndex) {
        newIndex = newIndex - 1;
      }
      // Insert after node
      if (nodes[newIndex].expanded) {
        movingNode.previousId = EMPTY_UUID;
        movingNode.parentId = nodes[newIndex].uuid;
        movingNode.indent = nodes[newIndex].indent + 1;
        movingNode.parent = nodes[newIndex];

        newSiblingIndex = 0;
        newSiblings = nodes[newIndex].children!;
        if (newSiblings.length > 0) {
          newSiblings[0].previousId = movingNode.uuid;
        }
      } else {
        movingNode.previousId = nodes[newIndex].uuid;
        movingNode.parentId = nodes[newIndex].parentId;
        movingNode.indent = nodes[newIndex].indent;
        movingNode.parent = nodes[newIndex].parent;

        if (nodes[newIndex].uuid != newSiblings.last.uuid) {
          for (int i = 0; i < newSiblings.length; i++) {
            if (newSiblings[i].uuid == nodes[newIndex].uuid) {
              newSiblings[i + 1].previousId = movingNode.previousId;
              newSiblingIndex = i + 1;
            }
          }
        }
      }
    }

    movingNode.expanded = lastNodeExpandState;

    NodeBean nodeToInsert = NodeBean.fromJson(movingNode.toJson());
    newSiblings.insert(newSiblingIndex, movingNode);

    ops.add(Operation(OperationType.DeleteNode,
        node: NodeBean.fromJson(nodeToDelete.toJson())));

    ops.add(Operation(OperationType.InsertNode,
        node: NodeBean.fromJson(nodeToInsert.toJson())));

    this.globalModel!.transactionDao!.transaction(Transaction(ops));
    notifyListeners();
  }

  onExpandNode(NodeBean node, {bool? value}) {
    if (value != null) {
      node.expanded = value;
    } else {
      node.expanded = !node.expanded;
    }
    notifyListeners();
  }

  onReorderStart(NodeBean node) {
    lastNodeExpandState = node.expanded;
    lastNodeReordering = node;
    debugPrint("onReorderStart " + lastNodeReordering!.uuid);
    node.expanded = false;
    notifyListeners();
  }

  onTapTeamIcon(int index) {
    this.currentTeamIndex = index;
    notifyListeners();
    this.globalModel!.triggerCallback(EventType.TEAM_SIDEBAR_INDEX_CHANGED);
  }
}
