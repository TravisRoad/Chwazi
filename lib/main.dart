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

class _MyAppstate extends State<MyApp> {
  Map<int, Widget> map = new Map();
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body: new Stack(
        children: <Widget>[
          Listener(
            child: Container(
              color: Colors.black,
            ),
            onPointerDown: (event) => setState(() {
              map.addAll(
                {
                  event.pointer: Shape(
                    pointer: event.pointer,
                    x: event.position.dx,
                    y: event.position.dy,
                  )
                },
              );
            }),
            onPointerMove: (event) => setState(() {
              map[event.pointer] = Shape(
                pointer: event.pointer,
                x: event.position.dx,
                y: event.position.dy,
              );
            }),
            onPointerUp: (event) => setState(() {
              _remove(event.pointer);
            }),
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
}
