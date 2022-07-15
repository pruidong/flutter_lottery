import 'package:flutter/material.dart';
import 'package:flutter_lottery/roulette_main.dart';
import 'package:flutter_lottery/scratcher_main.dart';

import 'data_list_edit.dart';

class APPMain extends StatefulWidget {
  const APPMain({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<APPMain> createState() => _APPMainState();
}

class _APPMainState extends State<APPMain> {
  int selected = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("幸运抽奖"),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const DataList(),
              ),
            );
            // 从编辑或新增返回后,重新加载一次数据.
          },
          tooltip: '抽奖项目列表',
          child: const Icon(Icons.list),
        ),
        drawer: Container(
          width: 300.00,
          margin: const EdgeInsets.fromLTRB(0, 10.0, 0, 0),
          color: Colors.white,
          child: ListView(
            // Important: Remove any padding from the ListView.
            // padding: EdgeInsets.zero,
            children: [
              ListTile(
                selected: selected == 0,
                title: Row(
                  children: const [
                    Icon(Icons.image_outlined),
                    Padding(padding: EdgeInsets.only(left: 5.0)),
                    Text('刮刮乐')
                  ],
                ),
                onTap: () {
                  setState(() {
                    selected = 0;
                  });
                  Navigator.pop(context);
                },
              ),
              ListTile(
                selected: selected == 1,
                title: Row(
                  children: const [
                    Icon(Icons.circle),
                    Padding(padding: EdgeInsets.only(left: 5.0)),
                    Text('转盘')
                  ],
                ),
                onTap: () {
                  // Update the state of the app.
                  // ...
                  setState(() {
                    selected = 1;
                  });
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        ),
        body: SingleChildScrollView(
            child:
                selected == 0 ? const ScratcherMain() : const RouletteMain()));
  }
}
