import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'constats.dart';

class DataList extends StatefulWidget {
  const DataList({Key? key}) : super(key: key);

  @override
  State<DataList> createState() => _DataListState();
}

class _DataListState extends State<DataList> {
  List<String> dataKeyList = [];

  @override
  void initState() {
    initData();
  }

  void initData() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> data = prefs
        .getKeys()
        .where((element) => element.contains(FLOTTERY_DATA_KEY_PREFIX))
        .map((e) => e.replaceFirst(FLOTTERY_DATA_KEY_PREFIX, ""))
        .toList();
    setState(() {
      dataKeyList = data;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("抽奖项目列表"),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const LotteryItemEdit(
                  itemKey: "",
                ),
              ),
            );
            // 从编辑或新增返回后,重新加载一次数据.
            initData();
          },
          tooltip: '新增一类项目',
          child: const Icon(Icons.add),
        ),
        body: ListView.builder(
            itemCount: dataKeyList.length,
            itemBuilder: (buildContext, index) {
              return ListTile(
                title: Text(dataKeyList[index]),
                onTap: () async {
                  // 从编辑或新增返回后,重新加载一次数据.
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => LotteryItemEdit(
                        itemKey: dataKeyList[index],
                      ),
                    ),
                  );
                  initData();
                },
              );
            }));
  }
}

class LotteryItemEdit extends StatefulWidget {
  final String itemKey;

  const LotteryItemEdit({Key? key, required this.itemKey}) : super(key: key);

  @override
  State<LotteryItemEdit> createState() => _LotteryItemEditState();
}

class _LotteryItemEditState extends State<LotteryItemEdit> {
  var title = "抽奖项目";
  var parentEditController = TextEditingController();
  var subEditController = TextEditingController();

  @override
  void initState() {
    initData();
  }

  void initData() async {
    var titleTemp = "抽奖项目新增";
    if (widget.itemKey != "") {
      titleTemp = "抽奖项目编辑";
    }
    // 加载历史数据.
    final prefs = await SharedPreferences.getInstance();
    var value = prefs.get(FLOTTERY_DATA_KEY_PREFIX + widget.itemKey) ?? "";
    parentEditController.text = widget.itemKey;
    subEditController.text = value.toString();
    setState(() {
      title = titleTemp;
    });
  }

  void saveData() async {
    var key = parentEditController.text;
    var value = subEditController.text;
    if (key.isEmpty || value.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("必填项不能为空!")));
      return;
    }

    // 去除空行
    List<String> valueList = value.toString().split("\n");
    valueList.removeWhere((element) => element == "" || element.trim() == "");
    if (valueList.length > 15) {
      valueList = valueList.sublist(0, 15);
    }
    var valueSet = valueList.toSet();
    if (valueSet.length < 3) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("去重之后,不能少于3项!")));
      return;
    }
    // 去重之后,再用换行符拼接起来.
    var valueSetString = valueSet.join("\n");

    // 保存历史数据.
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(
        FLOTTERY_DATA_KEY_PREFIX + parentEditController.text, valueSetString);

    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text("保存成功!")));
    Navigator.pop(context);
  }

  void deleteData() async {
    switch (await showDialog<String>(
        context: context,
        builder: (BuildContext context) {
          return SimpleDialog(
            title: const Text('确认删除吗?删除后不能恢复!'),
            children: <Widget>[
              SimpleDialogOption(
                onPressed: () {
                  Navigator.pop(context, "YES");
                },
                child: const Text('确认'),
              ),
              SimpleDialogOption(
                onPressed: () {
                  Navigator.pop(context, "NO");
                },
                child: const Text('取消'),
              ),
            ],
          );
        })) {
      case "YES":
        final prefs = await SharedPreferences.getInstance();
        prefs.remove(FLOTTERY_DATA_KEY_PREFIX + widget.itemKey);
        Navigator.pop(context);
        break;
      case "NO":
        // ...
        break;
      case null:
        break;
    }
  }

  @override
  void dispose() {
    super.dispose();
    parentEditController.dispose();
    subEditController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(title),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            saveData();
          },
          tooltip: '保存',
          child: const Icon(Icons.save),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("提示: 编辑数据将会覆盖原有数据"),
              ElevatedButton(
                style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(Colors.red)),
                onPressed: () {
                  deleteData();
                },
                child: Row(
                  children: const [Icon(Icons.delete), Text("删除")],
                ),
              ),
              const Divider(),
              const Text("大项名称:"),
              TextField(
                controller: parentEditController,
                maxLength: 20,
              ),
              const Divider(),
              const Text("子项(每行一条,仅会保留前15行):"),
              TextField(
                maxLines: 5,
                controller: subEditController,
              ),
            ],
          ),
        ));
  }
}
