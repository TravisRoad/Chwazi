import 'package:flutter/material.dart';
import 'shape.dart';
import 'dart:async';
import 'eventBus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'util.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(new MaterialApp(
    title: "chwazi",
    home: MyApp(),
  ));
}

class MyApp extends StatefulWidget {
  @override
  _MyAppstate createState() => new _MyAppstate();
}

class _MyAppstate extends State<MyApp> with WidgetsBindingObserver {
  Map<int, Pair<Shape, bool>> map = new Map();
  // late Widget floatingMenu;

  int selectNum = 1;
  int groupNum = 2;

  Status _status = Status.waiting;
  Mode _mode = Mode.select;

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body: new Stack(
        children: [
          Listener(
            child: Container(
              color: Colors.black,
            ),
            onPointerDown: (event) {
              setState(() {
                _onPointerDown(event);
              });
            },
            onPointerMove: (event) {
              setState(() {
                _onPointerMove(event);
              });
            },
            onPointerUp: (event) {
              print("spec:${event.pointer} up status->$_status");
              setState(() {
                _onPointerUp(event);
              });
            },
          )
        ]..addAll(map.values.map((e) => e.first)),
      ),
      floatingActionButton: ElevatedButton(
        style: ButtonStyle(
          shape: MaterialStateProperty.all(StadiumBorder(
              side: BorderSide(
            //设置 界面效果
            style: BorderStyle.solid,
          ))),
        ),
        onPressed: () => setState(() {
          if (_mode == Mode.select) {
            selectNum = selectNum % 3 + 1;
            saveTargetNum(selectNum);
          } else {
            groupNum = 1 + groupNum > 4 ? 2 : groupNum + 1;
          }
          HapticFeedback.lightImpact();
          HapticFeedback.vibrate();
        }),
        onLongPress: () => setState(() {
          if (_mode == Mode.group) {
            _mode = Mode.select;
          } else {
            _mode = Mode.group;
          }
          HapticFeedback.lightImpact();
          HapticFeedback.vibrate();
        }),
        child: Text(_mode == Mode.select
            ? selectNum.toString() + "F"
            : groupNum.toString() + "G"),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startTop,
    );
  }

  void removingNotice(int pointer) {
    print("removingNotice $pointer!");
    // 增加延时，防止订阅者无法接收到事件
    Timer(const Duration(milliseconds: 20),
        () => bus.emit(removeEvent + pointer.toString(), pointer));
  }

  void _remove(int pointer) {
    setState(() {
      map.remove(pointer);
      if (map.isEmpty) _status = Status.waiting;
    });
  }

  late Timer timer;
  bool t = false;
  @override
  void initState() {
    WidgetsBinding.instance!.addObserver(this);
    Timer.periodic(period, (timer) {
      _onVoting();
      this.timer = timer;
    });
    setState(() {
      _getTargetNum();
    });
    super.initState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance!.removeObserver(this);
    timer.cancel();
    saveTargetNum(selectNum);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
      case AppLifecycleState.inactive:
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
        setState(() {
          map.clear();
          _status = Status.waiting;
        });
        break;
    }
    super.didChangeAppLifecycleState(state);
  }

  void _addShape(PointerEvent event) {
    map.addAll({
      event.pointer: Pair(
        first: Shape(
          pointer: event.pointer,
          x: event.position.dx,
          y: event.position.dy,
          onReady: _ready,
          onRemove: _remove,
          color: ChooseColor.choose(event.pointer),
        ),
        last: false,
      )
    });
  }

  void _ready(int pointer, bool isReady) {
    map[pointer]!.last = isReady;
  }

  final period = const Duration(microseconds: 500);
  //选出
  void _onVoting() {
    if (_status == Status.waiting &&
        map.length > selectNum &&
        !map.values.map((e) => e.last).contains(false)) {
      _status = Status.voting;

      print("voting...");
      // 设定计时器
      Timer(const Duration(seconds: 1), () => _onVoted());
    }
  }

  // 投票！
  void _onVoted() {
    if (_status != Status.voting) return;
    List<int> list = map.keys.toList()..shuffle();
    if (_mode == Mode.select) {
      setState(() {
        for (int i = 0; i < selectNum; ++i) {
          bus.emit("remove", i);
        }
        for (int i = selectNum; i < list.length; i++) {
          // removingNotice(list[i]);
          if (selectNum == 1)
            _remove(list[i]);
          else
            removingNotice(list[i]);
        }
        _status = Status.voted;
      });
      print("voted...${map.keys.toList()[0]}");
      print(list);
      print(map);
      if (selectNum == 1) bus.emit(list[0]);
    } else {
      int i = -1;
      print(list.toList());
      list.forEach((element) => {print(map[element]!.first.color.toString())});
      setState(() => list.forEach((element) =>
          map[element]!.first.color = map[list[++i % groupNum]]!.first.color));
      _status = Status.voted;
      list.forEach((element) => {print(map[element]!.first.color.toString())});
      print("voted...");
    }
  }

  Future _getTargetNum() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    setState(() {
      if (sharedPreferences.containsKey("targetNum"))
        selectNum = sharedPreferences.getInt("targetNum")!;
      else
        selectNum = 1;
    });
  }

  /// 利用SharedPreferences存储数据
  void saveTargetNum(int value) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.setInt("targetNum", value);
  }

  void _onPointerMove(PointerMoveEvent event) {
    switch (_status) {
      case Status.voted:
        if (map.keys.contains(event.pointer)) {
          var _x = map[event.pointer]!.first.x;
          var _y = map[event.pointer]!.first.y;
          map[event.pointer] = Pair(
            first: Shape(
              pointer: event.pointer,
              x: _x + event.delta.dx,
              y: _y + event.delta.dy,
              onReady: _ready,
              onRemove: _remove,
              color: map[event.pointer]!.first.color,
            ),
            last: map[event.pointer]!.last,
          );
        }
        break;
      case Status.waiting:
      case Status.voting:
      default:
        if (map.keys.contains(event.pointer)) {
          var _x = map[event.pointer]!.first.x;
          var _y = map[event.pointer]!.first.y;
          map[event.pointer] = Pair(
            first: Shape(
              pointer: event.pointer,
              x: _x + event.delta.dx,
              y: _y + event.delta.dy,
              onReady: _ready,
              onRemove: _remove,
              color: ChooseColor.choose(event.pointer),
            ),
            last: map[event.pointer]!.last,
          );
        }
        break;
    }
  }

  void _onPointerDown(PointerDownEvent event) {
    HapticFeedback.heavyImpact();
    HapticFeedback.lightImpact();

    switch (_status) {
      case Status.waiting:
        _addShape(event);
        break;
      case Status.voting:
        _addShape(event);
        _status = Status.waiting;
        break;
      case Status.voted:
      default:
        break;
    }
  }

  void _onPointerUp(PointerUpEvent event) {
    switch (_status) {
      case Status.waiting:
        removingNotice(event.pointer);
        break;
      case Status.voting:
        removingNotice(event.pointer);
        _status = Status.waiting;
        break;
      case Status.voted:
        if (map.keys.contains(event.pointer)) {
          removingNotice(event.pointer);
        }
        break;
      default:
        break;
    }
  }
}
