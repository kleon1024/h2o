import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:h2o/bean/node.dart';
import 'package:h2o/components/nodes/basic_node.dart';
import 'package:h2o/dao/node.dart';
import 'package:h2o/global/icons.dart';
import 'package:h2o/model/document/document_page.dart';
import 'package:h2o/pages/document/document_page.dart';
import 'package:provider/provider.dart';

class DocumentNode extends StatelessWidget {
  final NodeBean nodeBean;

  const DocumentNode(this.nodeBean);

  @override
  Widget build(BuildContext context) {
    return BasicNode(
      expanded: false,
      indentLevel: 0,
      name: nodeBean.name,
      icon: IconMap.nodeType[NodeType.document],
      onTapNode: () {
        Navigator.of(context).push(
          CupertinoPageRoute(builder: (ctx) {
            return ChangeNotifierProvider(
                create: (_) => DocumentPageModel(context, nodeBean),
                child: DocumentPage());
          }),
        );
      },
      onTapPlus: () {},
    );
  }
}
