import 'dart:math';

import 'package:flutter/material.dart';
import 'package:scratcher/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'constats.dart';

class ScratcherMain extends StatefulWidget {
  const ScratcherMain({Key? key}) : super(key: key);

  @override
  State<ScratcherMain> createState() => _ScratcherMainState();
}

class _ScratcherMainState extends State<ScratcherMain> {
  List<String> keyData = [];
  List<String> valueData = [];

  //
  List<String> constValueDataList = [];
  List<Widget> widgetList = [];
  var selectedKey = "";
  List<GlobalKey<ScratcherState>> globalKey = [];

  // 默认项目.
  final FLOTTERY_DEFAULT_ITEM = "${FLOTTERY_DATA_KEY_PREFIX}_DEFAULT";

  @override
  void initState() {
    initPrefsData();
    initData();
  }

  //打乱数组
  void shuffle(List<String> arr) {
    var mRandom = Random();
    for (int i = arr.length; i > 0; i--) {
      int rand = mRandom.nextInt(i);
      swap(arr, rand, i - 1);
    }
  }

  //交换两个值
  void swap(List<String> a, int i, int j) {
    String temp = a[i];
    a[i] = a[j];
    a[j] = temp;
  }

  void initPrefsValue(String key) async {
    final prefs = await SharedPreferences.getInstance();
    var value = prefs.get(FLOTTERY_DATA_KEY_PREFIX + key);
    if (value != "") {
      var tempValueDataList = value.toString().split("\n");
      // 对过长的项目进行截取.
      var valueDataList = tempValueDataList
          .map((e) => e.length > 4 ? "${e.substring(0, 4)}.." : e)
          .toList();
      prefs.setString(FLOTTERY_DATA_SELECTED_KEY, key);
      setState(() {
        constValueDataList = tempValueDataList;
        valueData = valueDataList;
        selectedKey = key;
      });
      initData();
    }
  }

  Future<int> initPrefsData() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> checkData = prefs
        .getKeys()
        .where((element) => element.contains(FLOTTERY_DATA_KEY_PREFIX))
        .map((e) => e.replaceFirst(FLOTTERY_DATA_KEY_PREFIX, ""))
        .toList();
    setState(() {
      keyData = checkData;
    });
    if (keyData.isNotEmpty) {
      var selectedSaveKey = prefs.getString(FLOTTERY_DATA_SELECTED_KEY);
      String defaultKey = keyData[0];
      if (selectedSaveKey != null) {
        defaultKey = selectedSaveKey;
      }
      initPrefsValue(defaultKey);
    }
    return 0;
  }

  void clear() {
    for (var itemInfo in globalKey) {
      itemInfo.currentState?.reset();
    }
    initData();
  }

  void initData() {
    List<Widget> widgetListTemp = [];
    List<GlobalKey<ScratcherState>> globalKeyTemp = [];

    var borderColor = Colors.deepOrangeAccent;
    shuffle(valueData);
    for (var item in valueData) {
      var scratchKey = GlobalKey<ScratcherState>();
      globalKeyTemp.add(scratchKey);
      widgetListTemp.add(
        Container(
          width: 200,
          height: 200,
          margin: const EdgeInsets.all(10.0),
          padding: const EdgeInsets.all(10.0),
          child: Scratcher(
            key: scratchKey,
            brushSize: 30,
            threshold: 30,
            color: Colors.white,
            image: Image.asset("resource/image/circle.jpeg"),
            onChange: (value) => print("Scratch progress: $value%"),
            onThreshold: () {
              /*for (var itemInfo in globalKey) {
                itemInfo.currentState?.reveal();
              }*/
            },
            child: Container(
                height: 150,
                width: 150,
                decoration: BoxDecoration(
                    borderRadius: const BorderRadius.all(Radius.circular(500)),
                    border: Border(
                        top: BorderSide(color: borderColor),
                        bottom: BorderSide(color: borderColor),
                        right: BorderSide(color: borderColor),
                        left: BorderSide(color: borderColor))),
                child: Center(child: Text(item))),
          ),
        ),
      );
    }
    setState(() {
      globalKey = globalKeyTemp;
      widgetList = widgetListTemp;
    });
  }

  Future<void> _showLotteryOptions() async {
    await initPrefsData();
    List<Widget> widgetList = [];
    for (var element in keyData) {
      widgetList.add(SimpleDialogOption(
        onPressed: () {
          Navigator.pop(context, element);
        },
        child: Text(element),
      ));
    }

    var selectKey = await showDialog<String>(
        context: context,
        builder: (BuildContext context) {
          return SimpleDialog(
              title: const Text('选择抽奖项目'), children: widgetList);
        });
    if (selectKey != null) {
      initPrefsValue(selectKey);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(5.0),
              child: SizedBox(
                width: 150,
                child: ElevatedButton(
                  onPressed: () {
                    _showLotteryOptions();
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.select_all_sharp),
                      Text("抽奖项目")
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(
              width: 150,
              child: ElevatedButton(
                style: ButtonStyle(
                    backgroundColor:
                        MaterialStateProperty.all(Colors.deepOrange)),
                onPressed: () {
                  clear();
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [Icon(Icons.restart_alt), Text("重置")],
                ),
              ),
            ),
          ],
        ),
        Text(" $selectedKey"),
        SizedBox(
          width: double.infinity,
          height: 500,
          child: GridView.count(
            // Create a grid with 2 columns. If you change the scrollDirection to
            // horizontal, this produces 2 rows.
            crossAxisCount: 3,
            // Generate 100 widgets that display their index in the List.
            children: widgetList,
          ),
        )
      ],
    );
  }
}
