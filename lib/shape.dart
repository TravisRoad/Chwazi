import 'package:flutter/material.dart';

class Shape extends StatefulWidget {
  Shape({required this.top, required this.left});

  double top;
  double left;

  @override
  _MyAnimationState createState() => _MyAnimationState();
}

class _MyAnimationState extends State<Shape> with TickerProviderStateMixin {
  late Animation<double> expandingAnimation;
  // late Animation<double> extraAnimation;
  // late Animation<double> breathingAnimation;
  late AnimationController expandingController;
  late AnimationController breathingController;
  late AnimationController extraController;

  @override
  void initState() {
    super.initState();
    expandingController = new AnimationController(
        duration: const Duration(seconds: 3), vsync: this);
    extraController = new AnimationController(
        duration: const Duration(seconds: 3), vsync: this);
    breathingController = new AnimationController(
        duration: const Duration(seconds: 3), vsync: this);
    //图片宽高从0变到300
    expandingAnimation =
        new Tween(begin: 0.0, end: 300.0).animate(expandingController)
          ..addListener(() {
            setState(() => {});
          });
    //启动动画(正向执行)
    expandingController.forward();
  }

  @override
  Widget build(BuildContext context) {
    return new Center(
      child: CircleAvatar(
        radius: expandingAnimation.value,
        backgroundColor: Colors.blue,
        child: new Text('X'),
      ),
    );
  }

  @override
  void dispose() {
    expandingController.dispose();
    extraController.dispose();
    breathingController.dispose();
    super.dispose();
  }
}

void main() {
  runApp(new MaterialApp(
    title: 'Shopping App',
    home: new Shape(
      top: 1.0,
      left: 1.0,
    ),
  ));
}
