import 'package:flutter/material.dart';
import 'dart:math';

typedef readyCallBack(int pointer, bool isReady);

class Shape extends StatefulWidget {
  Shape({
    required this.pointer,
    required this.x,
    required this.y,
    required this.onReady,
  }) : color = colors[pointer % colors.length];

  int pointer;
  double x;
  double y;
  Color color;
  readyCallBack onReady;
  static List<Color> colors = [
    Colors.red,
    Colors.orange,
    Colors.white,
    Colors.lime,
    Colors.blue,
    Colors.cyan,
  ];

  @override
  _ShapeState createState() => new _ShapeState();
}

class _ShapeState extends State<Shape> with TickerProviderStateMixin {
  final double _maxRadius = 50.0;
  final double _maxBackgroud = 500.0;

  late AnimationController expandingController;
  late Animation<double> expandingAnimation;
  late AnimationController shrinkingController;
  late Animation<double> shrinkingAnimation;

  @override
  void initState() {
    expandingController = new AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );
    expandingAnimation =
        new Tween(begin: 20.0, end: _maxRadius).animate(expandingController)
          ..addStatusListener((status) {
            switch (status) {
              case AnimationStatus.dismissed:
                break;
              case AnimationStatus.forward:
                break;
              case AnimationStatus.reverse:
                widget.onReady(widget.pointer, false);
                break;
              case AnimationStatus.completed:
                widget.onReady(widget.pointer, true);
                break;
            }
          });
    shrinkingController = new AnimationController(
      vsync: this,
      duration: const Duration(microseconds: 1000),
    );
    shrinkingAnimation = new Tween(begin: _maxBackgroud, end: _maxRadius + 10.0)
        .animate(shrinkingController)
          ..addStatusListener((status) {
            switch (status) {
              case AnimationStatus.dismissed:
                // TODO: Handle this case.
                break;
              case AnimationStatus.forward:
                // TODO: Handle this case.
                break;
              case AnimationStatus.reverse:
                // TODO: Handle this case.
                break;
              case AnimationStatus.completed:
                // TODO: Handle this case.
                break;
            }
          });
    expandingController.forward();
  }

  @override
  void dispose() {
    expandingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: widget.y - expandingAnimation.value,
      left: widget.x - expandingAnimation.value,
      child: _Circle(
        radius: expandingAnimation.value,
        color: widget.color,
        value: expandingAnimation.value / _maxRadius,
      ),
    );
  }
}

class _Circle extends StatelessWidget {
  _Circle({
    required this.radius,
    this.color,
    required this.value,
  });

  double radius = 1.0;
  Color? color = Colors.red;
  double value;
  @override
  Widget build(BuildContext context) {
    // return SizedBox(
    //   width: radius * 2,
    //   height: radius * 2,
    //   child:
    return Stack(
      alignment: Alignment.center,
      children: [
        CircleAvatar(
          radius: radius - 5.0,
          backgroundColor: color,
        ),
        SizedBox(
          width: radius * 2,
          height: radius * 2,
          child: CircularProgressIndicator(
            color: color,
            value: value,
            backgroundColor: color!.withAlpha(10),
            strokeWidth: 4.0,
          ),
        )
      ],
    );
  }
}
