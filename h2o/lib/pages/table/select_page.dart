import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:h2o/bean/select.dart';
import 'package:h2o/components/scroll/bouncing_scroll_view.dart';
import 'package:h2o/components/table/square_chip.dart';
import 'package:h2o/model/global.dart';
import 'package:h2o/model/table/select_page.dart';
import 'package:h2o/pages/unified_page.dart';
import 'package:h2o/utils/color.dart';
import 'package:provider/provider.dart';

class SelectPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final globalModel = Provider.of<GlobalModel>(context);
    final selectPageModel = Provider.of<SelectPageModel>(context);

    return UnifiedPage(
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(36 + 60),
          child: AppBar(
            automaticallyImplyLeading: false,
            elevation: 0,
            centerTitle: true,
            backgroundColor: Colors.transparent,
            title: Text(selectPageModel.column.name,
                style: Theme.of(context)
                    .textTheme
                    .bodyText1!
                    .merge(TextStyle(fontWeight: FontWeight.bold))),
            titleSpacing: 0.0,
            actions: [
              InkWell(
                  onTap: () {
                    Navigator.of(context).pop();
                  },
                  child: Container(
                    width: 64,
                    child: Text(
                      tr("table.select.confirm"),
                    ),
                    alignment: Alignment.center,
                  )),
            ],
            bottom: PreferredSize(
              preferredSize: Size.fromHeight(60),
              child: GestureDetector(
                onTap: () {
                  FocusScope.of(context)
                      .requestFocus(selectPageModel.focusNode);
                },
                child: Container(
                  width: double.infinity,
                  color: Theme.of(context).cardColor,
                  padding: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                  child: Wrap(
                    spacing: 6,
                    runSpacing: 3,
                    children: [
                      SquareChip(
                        onPressed: () {},
                        backgroundColor: selectPageModel.color,
                        text: "ABC",
                      ),
                      Container(
                        width:
                            20.0 + selectPageModel.controller.text.length * 8,
                        child: TextField(
                          autofocus: true,
                          focusNode: selectPageModel.focusNode,
                          controller: selectPageModel.controller,
                          onChanged: selectPageModel.onTextFieldChanged,
                          style: Theme.of(context).textTheme.bodyText2,
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            isDense: true,
                            fillColor: Theme.of(context).cardColor,
                            filled: true,
                            contentPadding: EdgeInsets.symmetric(
                                vertical: 6, horizontal: 4),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        body: GestureDetector(
          onTap: () {
            FocusScope.of(context).requestFocus(FocusNode());
          },
          child: Container(
            child: BouncingScrollView(
              scrollBar: true,
              slivers: [
                SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    return Container(
                        width: double.infinity,
                        padding:
                            EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                        child: Text(tr("table.select.hint")));
                  }, childCount: 1),
                ),
                SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    SelectBean select = selectPageModel.matchedOptions[index];
                    debugPrint("select: " + select.color.toString());
                    return InkWell(
                      onTap: () {},
                      child: Container(
                          width: double.infinity,
                          alignment: Alignment.centerLeft,
                          padding:
                              EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                          color: Theme.of(context).cardColor,
                          child: SquareChip(
                              onPressed: () {},
                              backgroundColor:
                                  ColorUtil.ColorFromInt(select.color),
                              text: select.text)),
                    );
                  }, childCount: selectPageModel.matchedOptions.length),
                ),
                SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    if (selectPageModel.controller.text.trim().isEmpty ||
                        selectPageModel.exactlyMatched) {
                      return Container();
                    }
                    return InkWell(
                      onTap: selectPageModel.onCreateSelect,
                      child: Container(
                        width: double.infinity,
                        padding:
                            EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                        color: Theme.of(context).cardColor,
                        child: Wrap(
                          spacing: 6,
                          children: [
                            Text(tr("table.select.create")),
                            SquareChip(
                                backgroundColor: selectPageModel.color,
                                onPressed: selectPageModel.onCreateSelect,
                                text: selectPageModel.controller.text)
                          ],
                        ),
                      ),
                    );
                  }, childCount: 1),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
