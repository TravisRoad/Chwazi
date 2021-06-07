import 'package:flutter/material.dart';
import 'shape.dart';

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
  Map<int, Widget> map = new Map();
  List<int> readyList = [];

  int targetNum = 1;
  int _status = Status.wait;
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body: new Stack(
        children: <Widget>[
          Listener(
            child: Container(
              color: Colors.black,
            ),
            onPointerDown: (event) {
              if (_status == Status.wait) {
                setState(() {
                  map.addAll({
                    event.pointer: Shape(
                      pointer: event.pointer,
                      x: event.position.dx,
                      y: event.position.dy,
                      onReady: _ready,
                    ),
                  });
                });
              }
            },
            onPointerMove: (event) {
              if (_status == Status.wait) {
                setState(() {
                  map[event.pointer] = Shape(
                    pointer: event.pointer,
                    x: event.position.dx,
                    y: event.position.dy,
                    onReady: _ready,
                  );
                });
              }
            },
            onPointerUp: (event) {
              if (_status == Status.wait) {
                setState(() {
                  _remove(event.pointer);
                });
              } else if (_status == Status.voted &&
                  readyList.contains(event.pointer)) {
                _status = Status.wait;
                //TODO:调用销毁函数
                map.remove(event.pointer);
              }
            },
          )
        ]..addAll(map.values),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => setState(() => {}), // TODO: 设计选单
        tooltip: 'optional',
        child: const Icon(Icons.menu),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startTop,
    );
  }

  void _remove(int pointer) {
    map.remove(pointer);
  }

  @override
  void initState() {
    WidgetsBinding.instance!.addObserver(this);
    super.initState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance!.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      map.clear();
      readyList.clear();
    }
    super.didChangeAppLifecycleState(state);
  }

  void _ready(int pointer, bool isReady) {
    if (isReady) {
      readyList.add(pointer);
    } else {
      readyList.remove(pointer);
    }
    _vote();
  }

  //选出
  void _vote() {
    if (readyList.length > targetNum && readyList.length == map.length) {
      readyList.shuffle();
      for (int i = targetNum; i < readyList.length; i++) {
        map.remove(readyList[i]);
        readyList.removeAt(i);
      }
      // 更改状态，屏蔽事件效果
      _status = Status.voted;
      if (targetNum == 1) {
        //TODO:启动下层的Shrinking动画
      }
    }
  }
}

class Status {
  static final int wait = 0;
  static final int voted = 1;
}
