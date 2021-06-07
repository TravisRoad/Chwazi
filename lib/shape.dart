import 'package:flutter/material.dart';
import 'dart:math';

class Shape extends StatefulWidget {
  Shape({required this.pointer, required this.x, required this.y})
      : color = colors[pointer % colors.length];

  int pointer;
  double x;
  double y;
  Color color;
  static List<Color> colors = [
    Colors.red,
    Colors.orange,
    Colors.white,
    Colors.lime
  ];

  @override
  _ShapeState createState() => new _ShapeState();
}

class _ShapeState extends State<Shape> with TickerProviderStateMixin {
  final double maxRadius = 50.0;

  late AnimationController expandingController;
  late Animation<double> animation;

  @override
  void initState() {
    expandingController = new AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );
    animation =
        new Tween(begin: 20.0, end: maxRadius).animate(expandingController)
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
      top: widget.y - animation.value,
      left: widget.x - animation.value,
      child: _Circle(
        radius: animation.value,
        color: widget.color,
        value: animation.value / maxRadius,
      ),
    );
  }
}

class _Circle extends StatelessWidget {
  _Circle({required this.radius, this.color, required this.value});
  double radius = 1.0;
  Color? color = Colors.red;
  double value;
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: radius * 2,
      height: radius * 2,
      child: Stack(
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
        alignment: Alignment.center,
      ),
    );
  }
}
