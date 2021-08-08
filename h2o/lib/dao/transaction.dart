import 'package:channel/channel.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:h2o/bean/block.dart';
import 'package:h2o/bean/node.dart';
import 'package:h2o/model/global.dart';

enum OperationType {
  InsertNode,
  DeleteNode,
  UpdateNode,
  InsertBlock,
  DeleteBlock,
  UpdateBlock
}

class Operation {
  OperationType op;
  NodeBean? node;
  BlockBean? block;

  Operation(this.op, {this.node, this.block});
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
