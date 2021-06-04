import 'dart:math';

import 'package:chwazi/shapeRemake.dart';
import 'package:flutter/material.dart';

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

class _MyAppstate extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body: TouchingListener(),
      floatingActionButton: FloatingActionButton(
        onPressed: () => setState(() => {}), // TODO: 设计选单
        tooltip: 'optional',
        child: const Icon(Icons.menu),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startTop,
    );
  }
}

//接收处理Touch事件
class TouchingListener extends StatefulWidget {
  @override
  _TouchingListenerState createState() => new _TouchingListenerState();
}

class _TouchingListenerState extends State<TouchingListener>
    with WidgetsBindingObserver {
  Map<int, ShapeRM> map = new Map();
  Map<int, bool> readyMap = new Map();
  @override
  Widget build(BuildContext context) {
    return Listener(
      child: Stack(
        children: [
          Container(
            color: Colors.black,
          ),
        ]..addAll(map.values),
      ),
      // 按下屏幕生成Shape
      onPointerDown: (e) => setState(() {
        print(e);
        map.addAll({
          e.pointer: ShapeRM(
            pointer: e.pointer,
            left: e.position.dx,
            top: e.position.dy,
            ondisposed: _removeShape,
            onReady: _ready,
          )
        });
        print("${e.toString()}");
      }),
      onPointerMove: (e) => setState(() {
        map[e.pointer] = ShapeRM(
          pointer: e.pointer,
          top: e.position.dy,
          left: e.position.dx,
          ondisposed: _removeShape,
          onReady: _ready,
        );
      }),
      onPointerUp: (e) => setState(() {
        _removeShape(e.pointer);
      }),
    );
  }

  void _removeShape(int pointer) {
    readyMap.remove(pointer);
    map.remove(pointer);
  }

  void _ready(int pointer) {
    readyMap.addAll({pointer: true});
    print("shape $pointer is ready. ${readyMap.length}");
    if (readyMap.length >= 2 && map.length == readyMap.length) {
      _vote();
      print("vote among ${readyMap.length}");
    }
  }

  @override
  void initState() {
    print("init");
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
    if (state == AppLifecycleState.resumed) {
      setState(() {
        map.clear();
        readyMap.clear();
      });
    }
    super.didChangeAppLifecycleState(state);
  }

  void _vote() {
    var list = map.keys.toList()..shuffle();
    list.removeAt(0);
    list.forEach((element) {
      _removeShape(element);
    });
  }
}
