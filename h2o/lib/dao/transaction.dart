import 'package:channel/channel.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:h2o/bean/block.dart';
import 'package:h2o/bean/column.dart';
import 'package:h2o/bean/node.dart';
import 'package:h2o/bean/row.dart';
import 'package:h2o/db/db.dart';
import 'package:h2o/model/global.dart';

enum OperationType {
  InsertNode,
  DeleteNode,
  UpdateNode,
  InsertChannelBlock,
  DeleteChannelBlock,
  UpdateChannelBlock,
  InsertDocumentBlock,
  DeleteDocumentBlock,
  UpdateDocumentBlock,
  InsertTable,
  DeleteTable,
  UpdateTable,
  InsertColumn,
  DeleteColumn,
  UpdateColumn,
  InsertRow,
  DeleteRow,
  UpdateRow,
}

class Operation {
  OperationType type;
  NodeBean? node;
  BlockBean? block;
  ColumnBean? column;
  List<String>? columns;
  List<RowBean>? rows;

  Operation(this.type,
      {this.node, this.block, this.column, this.columns, this.rows});
}

class Transaction {
  List<Operation> operations;

  Transaction(this.operations);
}

class TransactionDao extends ChangeNotifier {
  BuildContext? context;
  CancelToken cancelToken = CancelToken();
  GlobalModel? globalModel;

  final localChannel = Channel<Transaction>();
  final remoteChannel = Channel<Transaction>();
  int backOffSeconds = 0;

  setContext(BuildContext context, GlobalModel globalModel) async {
    if (this.context == null) {
      this.context = context;
      this.globalModel = globalModel;
      globalModel.transactionDao = this;

      this.processLocal();
      this.processRemote();
    }
  }

  processLocal() async {
    while (true) {
      final event = await localChannel.receive();
      if (!event.isClosed) {
        var t = event.data!;
        for (var operation in t.operations) {
          debugPrint("++transaction " + operation.type.toString());
          switch (operation.type) {
            case OperationType.InsertNode:
              await DBProvider.db.insertNode(operation.node!);
              break;
            case OperationType.UpdateNode:
              await DBProvider.db.updateNode(operation.node!);
              break;
            case OperationType.DeleteNode:
              await DBProvider.db.deleteNode(operation.node!);
              break;
            case OperationType.InsertChannelBlock:
              await DBProvider.db.insertBlock(operation.block!);
              break;
            case OperationType.DeleteChannelBlock:
              await DBProvider.db.deleteBlock(operation.block!);
              break;
            case OperationType.UpdateChannelBlock:
              await DBProvider.db.updateBlock(operation.block!);
              break;
            case OperationType.InsertDocumentBlock:
              await DBProvider.db.insertDocumentBlock(operation.block!);
              break;
            case OperationType.UpdateDocumentBlock:
              await DBProvider.db.updateBlock(operation.block!);
              break;
            case OperationType.DeleteDocumentBlock:
              await DBProvider.db.deleteDocumentBlock(operation.block!);
              break;
            case OperationType.InsertTable:
              await DBProvider.db.insertTable(operation.node!);
              break;
            case OperationType.InsertColumn:
              await DBProvider.db.insertColumn(operation.column!);
              break;
            case OperationType.InsertRow:
              await DBProvider.db.insertRows(
                  operation.node!.uuid, operation.columns!, operation.rows!);
              this.globalModel!.blockDao!.chartBlockMap.clear();
              break;
            case OperationType.UpdateRow:
              await DBProvider.db.updateRows(
                  operation.node!.uuid, operation.columns!, operation.rows!);
              this.globalModel!.blockDao!.chartBlockMap.clear();
              break;
            default:
          }
        }

        debugPrint("process local transaction");
      }
    }
  }

  processRemote() async {
    while (true) {
      final event = await remoteChannel.receive();
      if (!event.isClosed) {
        debugPrint("process remote transaction");
      }
    }
  }

  transaction(Transaction transaction) {
    this.localChannel.send(transaction);
    this.remoteChannel.send(transaction);
  }
}
