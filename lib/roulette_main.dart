import 'dart:math';

import 'package:flutter/material.dart';
import 'package:roulette/roulette.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'constats.dart';

class RouletteMain extends StatefulWidget {
  const RouletteMain({Key? key}) : super(key: key);

  @override
  State<RouletteMain> createState() => _RouletteMainState();
}

class _RouletteMainState extends State<RouletteMain>
    with TickerProviderStateMixin {
  RouletteController? _controller;
  Widget? rouletteWidget;
  final _random = Random();
  String? selectedKey;

  final colors = <Color>[
    Colors.red.withAlpha(50),
    Colors.green.withAlpha(30),
    Colors.blue.withAlpha(70),
    Colors.yellow.withAlpha(90),
    Colors.amber.withAlpha(50),
    Colors.indigo.withAlpha(70),
    Colors.red.withAlpha(50),
    Colors.green.withAlpha(30),
    Colors.blue.withAlpha(70),
    Colors.yellow.withAlpha(90),
    Colors.amber.withAlpha(50),
    Colors.indigo.withAlpha(70),
    Colors.red.withAlpha(50),
    Colors.green.withAlpha(30),
    Colors.blue.withAlpha(70)
  ];

  List<String> values = [];
  List<String> keyData = [];

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

  void initPrefsValue(String key) async {
    final prefs = await SharedPreferences.getInstance();
    var value = prefs.get(FLOTTERY_DATA_KEY_PREFIX + key);
    if (value != "") {
      var tempValueDataList = value.toString().split("\n");
      // 对过长的项目进行截取.
      var valueDataList = tempValueDataList
          .map((e) => e.length > 20 ? "${e.substring(0, 4)}.." : e)
          .toList();
      prefs.setString(FLOTTERY_DATA_SELECTED_KEY, key);
      setState(() {
        selectedKey = key;
        values = valueDataList;
      });
      final group = RouletteGroup.uniform(
        values.length,
        colorBuilder: colors.elementAt,
        textBuilder: (index) => values[index],
        textStyleBuilder: (index) {
          // Set the text style here!
          return const TextStyle(
            fontSize: 14,
          );
        },
      );
      _controller?.group = group;
    }
  }

  @override
  void initState() {
    final group = RouletteGroup.uniform(
      values.length,
      colorBuilder: colors.elementAt,
      textBuilder: (index) => values[index],
      textStyleBuilder: (index) {},
    );
    _controller = RouletteController(group: group, vsync: this);
    initPrefsData();
    super.initState();
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var rouletteWidget = Roulette(
      // Provide controller to update its state
      controller: _controller!,
      // Configure roulette's appearance
      style: const RouletteStyle(
        dividerThickness: 4,
        textLayoutBias: .8,
        centerStickerColor: Colors.amber,
      ),
    );
    return _controller == null
        ? Container()
        : Container(
            decoration: BoxDecoration(
              color: Colors.pink.withOpacity(0.1),
            ),
            width: double.infinity,
            height: 700.00,
            padding: const EdgeInsets.only(top: 30, left: 10, right: 10),
            child: Stack(
              alignment: Alignment.topCenter,
              children: [
                rouletteWidget,
                const Padding(
                  padding: EdgeInsets.only(top: 160),
                  child: Arrow(),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 145),
                  child: IconButton(
                      onPressed: () async {
                        var randomInt = Random();
                        var index = randomInt.nextInt(values.length);
                        await _controller?.rollTo(index,
                            offset: _random.nextDouble());
                        // TODO: Do something when roulette stopped here.
                      },
                      icon:
                          const Icon(Icons.refresh_sharp, color: Colors.white)),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 450),
                  child: selectedKey != null
                      ? Text("$selectedKey ")
                      : const Text(""),
                ),
                Padding(
                  padding:
                      const EdgeInsets.only(top: 480.0, left: 20, right: 20),
                  child: SizedBox(
                    width: 150.0,
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
                )
              ],
            ));
  }
}

class Arrow extends StatelessWidget {
  const Arrow({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 20,
      height: 36,
      child: CustomPaint(painter: _ArrowPainter()),
    );
  }
}

class _ArrowPainter extends CustomPainter {
  final _paint = Paint()
    ..color = Colors.amber
    ..style = PaintingStyle.fill;

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..lineTo(0, 0)
      ..relativeLineTo(size.width / 2, -size.height)
      ..relativeLineTo(size.width / 2, size.height)
      ..close();
    canvas.drawPath(path, _paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
