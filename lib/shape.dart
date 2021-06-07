import 'package:flutter/material.dart';
import 'eventBus.dart';

typedef ReadyCallBack(int pointer, bool isReady);

class ChooseColor {
  static Color? choose(pointer) => colors[pointer % colors.length];
  static List<Color?> colors = [
    Colors.red[400],
    Colors.orange,
    Colors.white,
    Colors.lime,
    Colors.blue,
    Colors.cyan,
    Colors.purple,
    Colors.greenAccent,
    Colors.green,
  ];
}

class Shape extends StatefulWidget {
  Shape({
    required this.pointer,
    required this.x,
    required this.y,
    required this.onReady,
    required this.color,
  }) : super(key: ObjectKey(pointer));

  int pointer;
  double x;
  double y;
  Color? color;
  ReadyCallBack onReady;

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
  late AnimationController breathingController;
  late Animation<double> breathingAnimation;

  late bool _isVoted;
  late double shrinkingVal;

  @override
  void initState() {
    print('${this} init ${widget.pointer}');
    shrinkingVal = 1.0;
    _isVoted = false;
    expandingController = new AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    expandingAnimation =
        new Tween(begin: 20.0, end: _maxRadius).animate(expandingController)
          ..addListener(() => setState(() => {}))
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
      duration: const Duration(milliseconds: 700),
    );
    shrinkingAnimation = new Tween(begin: _maxBackgroud, end: _maxRadius + 30.0)
        .animate(shrinkingController)
          ..addListener(() => setState(() {
                shrinkingVal = shrinkingAnimation.value;
                print(shrinkingVal);
              }))
          ..addStatusListener((status) {
            switch (status) {
              case AnimationStatus.dismissed:
                // TODO: Handle this case.
                break;
              case AnimationStatus.forward:
                print("gooooooooo!");
                break;
              case AnimationStatus.reverse:
                // TODO: Handle this case.
                break;
              case AnimationStatus.completed:
                shrinkingVal = _maxRadius + 30.0;

                break;
            }
          });
    breathingController = new AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    breathingAnimation = new Tween(begin: 0.95, end: 1.15)
        .animate(breathingController)
          ..addListener(() => setState(() => {}));

    breathingController.repeat(reverse: true);
    expandingController.forward();

    bus.on(topic0, _voted); // 订阅，提供回调函数
    bus.on("remove", _remove); // 订阅，提供回调函数
  }

  void _remove(pointer) {
    print("remove!");
    if (widget.pointer != pointer) {}
  }

  @override
  void dispose() {
    expandingController.dispose();
    breathingController.dispose();
    shrinkingController.dispose();
    bus.off(topic0); // 关闭订阅
    bus.off("remove"); // 关闭订阅
    super.dispose();
    print("${this} ${widget.pointer} disposed!");
  }

  @override
  Widget build(BuildContext context) {
    var _value = expandingAnimation.value * breathingAnimation.value;
    var _proportion = expandingAnimation.value / _maxRadius;
    // print("_isVoted:${_isVoted}");
    return Stack(
      children: [
        Mybackground(
          top: widget.y,
          left: widget.x,
          radius: shrinkingVal,
          color: widget.color,
          offset: shrinkingVal,
          isVoted: _isVoted,
        ),
        MyCircle(
          top: widget.y - _value,
          left: widget.x - _value,
          radius: _value,
          color: widget.color,
          value: _proportion,
        ),
      ],
    );
  }

  // 被选中时提供回调方法
  void _voted(useless) {
    _isVoted = true;
    shrinkingController.forward();
    print("$_isVoted!!! ${widget.pointer}");
    print("$this voted ${widget.pointer}");
  }
}

class MyCircle extends StatefulWidget {
  MyCircle({
    required this.radius,
    required this.color,
    required this.value,
    required this.top,
    required this.left,
  });

  double radius = 1.0;
  Color? color = Colors.red;
  double value;
  double top;
  double left;

  @override
  _MyCircleState createState() => new _MyCircleState();
}

class _MyCircleState extends State<MyCircle> {
  @override
  Widget build(BuildContext context) {
    // return SizedBox(
    //   width: radius * 2,
    //   height: radius * 2,
    //   child:
    return Positioned(
      top: widget.top,
      left: widget.left,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CircleAvatar(
            radius: widget.radius - 10.0,
            backgroundColor: widget.color!.withOpacity(0.70),
          ),
          SizedBox(
            width: widget.radius * 2,
            height: widget.radius * 2,
            child: CircularProgressIndicator(
              color: widget.color,
              value: widget.value,
              backgroundColor: widget.color!.withAlpha(128).withOpacity(0.50),
              strokeWidth: 6.0,
            ),
          )
        ],
      ),
    );
  }
}

class Mybackground extends StatefulWidget {
  final double maxRadius = 1000.0;

  Mybackground({
    required this.radius,
    required this.color,
    required this.offset,
    required this.isVoted,
    required this.top,
    required this.left,
  });
  double radius;
  Color? color;
  double offset;
  bool isVoted;
  double top;
  double left;

  final double min = 1.0;

  @override
  _MyBackground createState() => new _MyBackground();
}

class _MyBackground extends State<Mybackground> {
  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: widget.top - (widget.isVoted ? widget.maxRadius : widget.min),
      left: widget.left - (widget.isVoted ? widget.maxRadius : widget.min),
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            height: widget.isVoted ? widget.maxRadius * 2 : widget.min * 2,
            width: widget.isVoted ? widget.maxRadius * 2 : widget.min * 2,
            child: Opacity(
              opacity: 0.9,
              child: CircleAvatar(
                backgroundColor: widget.color,
                radius: widget.isVoted ? widget.maxRadius : widget.min,
              ),
            ),
          ),
          SizedBox(
            height: widget.isVoted ? widget.radius * 2 : widget.min * 2,
            width: widget.isVoted ? widget.radius * 2 : widget.min * 2,
            child: Opacity(
              opacity: 0.9,
              child: CircleAvatar(
                backgroundColor: Colors.black,
                radius: widget.radius,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
