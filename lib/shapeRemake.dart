import 'package:flutter/material.dart';

typedef AnimationEndCallback(int pointer);
typedef ReadyCallback(int pointer);

class ShapeRM extends StatefulWidget {
  ShapeRM({
    required this.pointer,
    required this.left,
    required this.top,
    required this.ondisposed,
    required this.onReady,
  });

  int pointer;
  double top;
  double left;
  final AnimationEndCallback ondisposed;
  final ReadyCallback onReady;
  // static GlobalKey<_ShapeRMstate> globalKey = GlobalKey();

  @override
  _ShapeRMstate createState() => new _ShapeRMstate();
}

class _ShapeRMstate extends State<ShapeRM> with TickerProviderStateMixin {
  final double _radius = 7.0;
  late AnimationController expandingController;
  late Animation<double> expandingAnimation;
  // late AnimationController breathingController;
  // late Animation<double> breathingAnimation;
  late double _top = widget.top;
  late double _left = widget.left;

  bool _isReady = false;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: widget.top - expandingAnimation.value,
      left: widget.left - expandingAnimation.value,
      child: ScaleTransition(
        alignment: Alignment.center,
        scale: expandingAnimation,
        child: new CircleAvatar(
          child: Text(
            "",
            textAlign: TextAlign.center,
          ),
          radius: expandingAnimation.value,
          backgroundColor: Colors.blue,
        ),
      ),
    );
  }

  @override
  void dispose() {
    print("${widget.pointer} has been disposed!");
    expandingController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    expandingController = new AnimationController(
        duration: const Duration(microseconds: 10000), vsync: this);
    expandingAnimation =
        new Tween(begin: 0.0, end: _radius).animate(expandingController)
          ..addListener(() {
            setState(() {});
          });
    expandingController.addStatusListener((status) {
      switch (status) {
        case AnimationStatus.completed:
          widget.onReady(widget.pointer);
          _isReady = true;
          break;
        case AnimationStatus.dismissed:
          widget.ondisposed(widget.pointer);
          dispose();
          break;
        case AnimationStatus.forward:
          _isReady = false;
          break;
        case AnimationStatus.reverse:
          _isReady = false;
          break;
      }
    });
    expandingController.forward();
  }

  void test() {
    print("hello,world!");
  }
}
