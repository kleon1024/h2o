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
import 'package:h2o/pages/unified_page.dart';
import 'package:provider/provider.dart';

class AddColumnPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final globalModel = Provider.of<GlobalModel>(context);
    final addColumnPageModel = Provider.of<AddColumnPageModel>(context);

    var bodyTestStyle = Theme.of(context).textTheme.bodyText2!;
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
                  autofocus: true,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r"^[^\s].*")),
                  ],
                  onChanged: addColumnPageModel.onTextFieldChanged,
                  controller: addColumnPageModel.controller,
                  textInputAction: TextInputAction.done,
                  keyboardType: TextInputType.text,
                  decoration: InputDecoration(
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                    fillColor: Colors.black26,
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
            dense: true,
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
              Icon(IconMap.columnType[columnType])
            ]),
            tileColor: Colors.black26,
            value: columnType,
            groupValue: addColumnPageModel.columnType,
            onChanged: addColumnPageModel.onColumnTypeRadioChanged,
          );
        }, childCount: ColumnType.values.length),
      ),
    ];

    Widget? defaultWidget;
    switch (addColumnPageModel.columnType) {
      case ColumnType.string:
        defaultWidget = TextField(
          style: Theme.of(context).textTheme.bodyText1,
          onChanged: addColumnPageModel.onDefaultStringValueTextFieldChanged,
          controller: addColumnPageModel.defaultValueController,
          textInputAction: TextInputAction.done,
          keyboardType: TextInputType.text,
          decoration: InputDecoration(
            contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
            fillColor: Colors.black26,
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
        );
        break;
      case ColumnType.integer:
        defaultWidget = TextField(
          style: Theme.of(context).textTheme.bodyText1,
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r"[0-9]")),
          ],
          onChanged: addColumnPageModel.onDefaultIntegerValueTextFieldChanged,
          controller: addColumnPageModel.defaultValueController,
          textInputAction: TextInputAction.done,
          keyboardType: TextInputType.text,
          decoration: InputDecoration(
            contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
            fillColor: Colors.black26,
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
        );
        break;
      case ColumnType.number:
        defaultWidget = TextField(
          style: Theme.of(context).textTheme.bodyText1,
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r"^[1-9.][0-9.]*")),
          ],
          onChanged: addColumnPageModel.onDefaultIntegerValueTextFieldChanged,
          controller: addColumnPageModel.defaultValueController,
          textInputAction: TextInputAction.done,
          keyboardType: TextInputType.text,
          decoration: InputDecoration(
            contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
            fillColor: Colors.black26,
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
        );
        break;
      case ColumnType.date:
        defaultWidget = Container(
          child: Placeholder(
            fallbackHeight: 30,
          ),
        );
        break;
      default:
        defaultWidget = null;
    }

    if (defaultWidget != null) {
      slivers.add(
        SliverList(
          delegate: SliverChildBuilderDelegate((context, index) {
            return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 15,
                  ),
                  Container(
                      padding:
                          EdgeInsets.symmetric(vertical: 6, horizontal: 10),
                      child: Text(
                        tr("table.add_column.default"),
                        style: Theme.of(context).textTheme.bodyText1,
                      ))
                ]);
          }, childCount: 1),
        ),
      );
      slivers.add(SliverList(
        delegate: SliverChildBuilderDelegate((context, index) {
          return defaultWidget;
        }, childCount: 1),
      ));
    }

    // if (addColumnPageModel.columnType == ColumnType.integer) {
    //   slivers.add(SliverList(
    //     delegate: SliverChildBuilderDelegate((context, index) {
    //       return Container(
    //         child: Row(
    //           children: [
    //             Checkbox(
    //               visualDensity: VisualDensity.compact,
    //               value: addColumnPageModel.autoIncrement,
    //               onChanged: addColumnPageModel.onAutoIncrementChanged,
    //             ),
    //             Text(tr("table.add_column.autoincrement")),
    //           ],
    //         ),
    //       );
    //     }, childCount: 1),
    //   ));
    // }

    // if (addColumnPageModel.columnType == ColumnType.date) {
    //   slivers.add(SliverList(
    //     delegate: SliverChildBuilderDelegate((context, index) {
    //       return Container(
    //         child: Row(
    //           children: [
    //             Checkbox(
    //               visualDensity: VisualDensity.compact,
    //               value: addColumnPageModel.currentTime,
    //               onChanged: addColumnPageModel.onAutoIncrementChanged,
    //             ),
    //             Text(tr("table.add_column.current_date")),
    //           ],
    //         ),
    //       );
    //     }, childCount: 1),
    //   ));
    // }

    slivers.add(SliverList(
      delegate: SliverChildBuilderDelegate((context, index) {
        return Container(
          height: 60,
        );
      }, childCount: 1),
    ));

    return UnifiedPage(
      child: Scaffold(
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
            backgroundColor: Colors.transparent,
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
        body: GestureDetector(
          onTap: () {
            FocusScope.of(context).requestFocus(FocusNode());
          },
          child: Container(
            child: BouncingScrollView(
              scrollBar: true,
              slivers: slivers,
            ),
          ),
        ),
      ),
    );
  }
}
