import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:h2o/components/blocks/block.dart';
import 'package:h2o/components/scroll/bouncing_scroll_view.dart';
import 'package:h2o/global/enum.dart';

class ChannelPage extends StatelessWidget {
  final TextEditingController _editingController = TextEditingController();

  final blocks = [
    BlockType.h1,
    BlockType.text,
    BlockType.bulleted_list,
    BlockType.bulleted_list,
    BlockType.bulleted_list,
    BlockType.numbered_list,
  ];

  @override
  Widget build(BuildContext context) {
    _editingController.text = "";

    OutlineInputBorder inputBorder = OutlineInputBorder(
      borderRadius: const BorderRadius.all(
        const Radius.circular(10),
      ),
      borderSide: BorderSide(color: Colors.transparent),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(tr("app.title")),
        actions: [
          IconButton(onPressed: () {}, icon: Icon(Icons.search)),
          IconButton(onPressed: () {}, icon: Icon(Icons.group)),
        ],
      ),
      body: Column(children: [
        Expanded(
          child: BouncingScrollView(
            scrollBar: true,
            reverse: true,
            slivers: [
              SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  return Container(
                      padding: EdgeInsets.symmetric(
                        vertical: 10,
                        horizontal: 20,
                      ),
                      child: Block(
                        type: blocks[index],
                        showCreator: true,
                      ));
                }, childCount: blocks.length),
              ),
            ],
          ),
        ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 10),
          height: 80,
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  style: Theme.of(context).textTheme.bodyText1,
                  controller: _editingController,
                  textInputAction: TextInputAction.send,
                  keyboardType: TextInputType.text,
                  decoration: InputDecoration(
                    isDense: true,
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                    fillColor: Theme.of(context).highlightColor,
                    filled: true,
                    hintText: "Input Here",
                    enabledBorder: inputBorder,
                    focusedBorder: inputBorder,
                  ),
                ),
              ),
              InkWell(
                onTap: () {},
                child: Icon(
                  CupertinoIcons.plus,
                ),
              ),
            ],
          ),
        )
      ]),
    );
  }
}
