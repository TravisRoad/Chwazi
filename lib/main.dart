import 'package:flutter/material.dart';
import 'shape.dart';

void main() {
  runApp(new MaterialApp(
    title: "chwazi",
    home: test(),
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
      body: new Drag(
        color: Colors.black,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => setState(() => {}), // TODO: 设计选单
        tooltip: 'optional',
        child: const Icon(Icons.menu),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startTop,
    );
  }
}

class Drag extends StatefulWidget {
  Drag({required this.color}) : super(key: new ObjectKey(color));
  Color color;

  @override
  _DragState createState() => new _DragState();
}

class _DragState extends State<Drag> with TickerProviderStateMixin {
  double _top = 100.0; //距顶部的偏移
  double _left = 100.0; //距左边的偏移

  List<Shape> shapes = <Shape>[];
  late Stack _stack;
  late GestureDetector _gestureDetector;

  @override
  Widget build(BuildContext context) {
    _gestureDetector = GestureDetector(
      child: Stack(
        children: <Widget>[
          Container(
            color: Colors.black,
          ),
        ]..addAll(shapes),
      ),
      onPanDown: (DragDownDetails e) {
        setState(() {
          // shapes.add(new Shape(x: e.globalPosition.dx, y: e.globalPosition.dy));
          shapes.add(Shape(
            left: _left,
            top: _top,
          ));
        });
        print("${e.globalPosition}");
      },
      onPanUpdate: (DragUpdateDetails e) {
        setState(() {
          dynamic p = shapes.last;
        });
      },
      onPanEnd: (DragEndDetails e) {},
    );
    return _gestureDetector;
  }
}

class test extends StatefulWidget {
  @override
  _test createState() => new _test();
}

class _test extends State<test> {
  PointerEvent? _event;
  int cnt = 0;
  List<Widget> lz = <Widget>[];
  List<int> idlz = <int>[];
  Map<int, Widget> ss = new Map<int, Widget>();

  @override
  Widget build(BuildContext context) {
    return Listener(
      child: Stack(
        children: [
          Container(
            alignment: Alignment.center,
            color: Colors.blue,
            child: Text("id: ${_event?.pointer ?? -1} \n" +
                "cnt:$cnt \n" +
                "${idlz.toString()}\n" +
                "ss.length: ${ss.length}"),
          ),
        ]..addAll(ss.values),
      ),
      onPointerDown: (PointerDownEvent event) => setState(() {
        _event = event;
        ++cnt;
        print("${event.toString()}");
        print("$cnt");
        idlz.add(event.pointer);
        ss.addAll({
          event.pointer: new Positioned(
              top: 100,
              left: 100,
              child: CircleAvatar(
                child: Text("${event.pointer}"),
              )),
        });
      }),
      onPointerMove: (PointerMoveEvent event) => setState(() {
        _event = event;
      }),
      onPointerUp: (PointerUpEvent event) => setState(() {
        _event = event;
        --cnt;
        idlz.remove(event.pointer);
        ss.remove(event.pointer);
      }),
    );
  }
}
