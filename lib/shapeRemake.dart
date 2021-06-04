import 'package:flutter/material.dart';

typedef AnimationEndCallback(int pointer);
typedef ReadyCallback(int pointer);

class ShapeRM extends StatefulWidget {
  ShapeRM({
    required this.pointer,
    required this.left,
    required this.top,
    required this.onAnimationEnd,
    required this.onReady,
  });
  int pointer;
  double top;
  double left;
  final AnimationEndCallback onAnimationEnd;
  final ReadyCallback onReady;
  @override
  _ShapeRMstate createState() => new _ShapeRMstate();
}

class _ShapeRMstate extends State<ShapeRM> {
  final double _radius = 40.0;
  @override
  Widget build(BuildContext context) {
    return Positioned(
      child: new CircleAvatar(
        child: Text("X"),
        radius: _radius,
        backgroundColor: Colors.blue,
      ),
      top: widget.top - _radius,
      left: widget.left - _radius,
    );
  }
}
