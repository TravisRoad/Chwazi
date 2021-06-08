import 'package:flutter/material.dart';
import 'shape.dart';
import 'dart:async';
import 'eventBus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'util.dart';

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

  late int targetNum = 1;
  int _status = Status.waiting;

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
        // ..add(floatingMenu),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue,
        onPressed: () => {
          setState(() {
            targetNum = targetNum % 3 + 1;
            saveTargetNum(targetNum);
          })
        },
        tooltip: 'change target',
        child: Text(targetNum.toString() + "F"),
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
  @override
  void initState() {
    WidgetsBinding.instance!.addObserver(this);
    Timer.periodic(period, (timer) {
      _vote();
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
    saveTargetNum(targetNum);
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
  void _vote() {
    if (_status == Status.waiting &&
        map.length > targetNum &&
        !map.values.map((e) => e.last).contains(false)) {
      _status = Status.voting;

      print("voting...");
      // 设定计时器
      Timer(const Duration(seconds: 1), () => _voted());
    }
  }

  // 投票！
  void _voted() {
    if (_status == Status.voting) {
      List<int> list = map.keys.toList()..shuffle();
      int min = list[0];
      setState(() {
        int min = list[0];
        for (int i = 0; i < targetNum; ++i) {
          bus.emit("remove", i);
        }
        for (int i = targetNum; i < list.length; i++) {
          // removingNotice(list[i]);
          if (targetNum == 1)
            _remove(list[i]);
          else
            removingNotice(list[i]);
          if (list[i] < min) min = list[i];
        }
        _status = Status.voted;
      });
      print("voted...${map.keys.toList()[0]}");
      print(list);
      print(map);
      if (targetNum == 1) bus.emit(list[0]);
    }
  }

  Future _getTargetNum() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    setState(() {
      if (sharedPreferences.containsKey("targetNum"))
        targetNum = sharedPreferences.getInt("targetNum")!;
      else
        targetNum = 1;
    });
  }

  /// 利用SharedPreferences存储数据
  void saveTargetNum(int value) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.setInt("targetNum", value);
  }

  void _onPointerMove(PointerMoveEvent event) {
    switch (_status) {
      case Status.waiting:
      case Status.voting:
      case Status.voted:
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
