import 'package:easy_localization/easy_localization.dart';
import 'package:enum_to_string/enum_to_string.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:h2o/components/scroll/bouncing_scroll_view.dart';
import 'package:h2o/dao/table.dart';
import 'package:h2o/global/icons.dart';
import 'package:h2o/model/global.dart';
import 'package:h2o/model/table/add_column_page.dart';
import 'package:provider/provider.dart';

class AddColumnPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final globalModel = Provider.of<GlobalModel>(context);
    final addColumnPageModel = Provider.of<AddColumnPageModel>(context);

    var bodyTestStyle = Theme.of(context).textTheme.bodyText1!;
    if (!addColumnPageModel.isNameValid) {
      bodyTestStyle =
          bodyTestStyle.merge(TextStyle(color: Theme.of(context).cardColor));
    }

    var slivers = [
      SliverList(
        delegate: SliverChildBuilderDelegate((context, index) {
          return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 15,
                ),
                Container(
                    padding: EdgeInsets.symmetric(vertical: 6, horizontal: 10),
                    child: Text(
                      tr("table.add_column.name"),
                      style: Theme.of(context).textTheme.bodyText1,
                    )),
                TextField(
                  style: Theme.of(context).textTheme.bodyText1,
                  inputFormatters: [
                    FilteringTextInputFormatter.deny(
                        RegExp(r"[/:;$@#%^*+=\|~]")),
                  ],
                  autofocus: true,
                  onChanged: addColumnPageModel.onTextFieldChanged,
                  controller: addColumnPageModel.controller,
                  textInputAction: TextInputAction.done,
                  keyboardType: TextInputType.text,
                  decoration: InputDecoration(
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                    fillColor: Theme.of(context).canvasColor,
                    filled: true,
                    border: InputBorder.none,
                    suffix: InkWell(
                      onTap: () {
                        addColumnPageModel.controller.clear();
                      },
                      child: Container(
                        padding: EdgeInsets.only(right: 8),
                        child: Icon(CupertinoIcons.clear_circled,
                            size: 16, color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ]);
        }, childCount: 1),
      ),
      SliverList(
        delegate: SliverChildBuilderDelegate((context, index) {
          return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 15,
                ),
                Container(
                    padding: EdgeInsets.symmetric(vertical: 6, horizontal: 10),
                    child: Text(
                      tr("table.add_column.type"),
                      style: Theme.of(context).textTheme.bodyText1,
                    ))
              ]);
        }, childCount: 1),
      ),
      SliverList(
        delegate: SliverChildBuilderDelegate((context, index) {
          ColumnType columnType = ColumnType.values[index];
          return RadioListTile<ColumnType>(
            title: Row(children: [
              Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    Text(
                      tr("table.add_column.type." +
                          EnumToString.convertToString(columnType)),
                      style: Theme.of(context).textTheme.bodyText1,
                    ),
                    Text(
                      tr("table.add_column.type." +
                          EnumToString.convertToString(columnType) +
                          ".description"),
                      style: Theme.of(context).textTheme.caption,
                    ),
                  ])),
              Icon(IconMap.columnType[columnType], size: 16)
            ]),
            tileColor: Theme.of(context).canvasColor,
            value: columnType,
            groupValue: addColumnPageModel.columnType,
            onChanged: addColumnPageModel.onColumnTypeRadioChanged,
          );
        }, childCount: ColumnType.values.length),
      ),
    ];

    return Scaffold(
      backgroundColor: Theme.of(context).cardColor,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(36),
        child: AppBar(
          automaticallyImplyLeading: false,
          elevation: 0,
          centerTitle: true,
          leading: InkWell(
              onTap: () {
                Navigator.pop(context);
              },
              child: Container(
                width: 64,
                child: Text(tr("table.add_column.cancel")),
                alignment: Alignment.center,
              )),
          backgroundColor: Theme.of(context).canvasColor,
          title: Text(tr("table.add_column.title"),
              style: Theme.of(context)
                  .textTheme
                  .bodyText1!
                  .merge(TextStyle(fontWeight: FontWeight.bold))),
          titleSpacing: 0.0,
          actions: [
            InkWell(
                onTap: addColumnPageModel.isNameValid
                    ? addColumnPageModel.onTapCreateColumn
                    : null,
                child: Container(
                  width: 64,
                  child: Text(
                    tr("table.add_column.confirm"),
                    style: bodyTestStyle,
                  ),
                  alignment: Alignment.center,
                )),
          ],
        ),
      ),
      body: Container(
        child: BouncingScrollView(
          scrollBar: true,
          slivers: slivers,
        ),
      ),
    );
  }
}
