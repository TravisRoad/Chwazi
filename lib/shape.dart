import 'package:flutter/material.dart';
import 'eventBus.dart';

typedef ReadyCallBack(int pointer, bool isReady);
typedef RemoveCallBack(int pointer);

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
    required this.onRemove,
  }) : super(key: ObjectKey(pointer));

  int pointer;
  double x;
  double y;
  Color? color;
  ReadyCallBack onReady;
  RemoveCallBack onRemove;

  @override
  _ShapeState createState() => new _ShapeState();
}

class _ShapeState extends State<Shape> with TickerProviderStateMixin {
  final double _maxRadius = 45.0;
  final double _maxBackgroud = 500.0;

  late AnimationController expandingController;
  late Animation<double> expandingAnimation;
  late AnimationController shrinkingController;
  late Animation<double> shrinkingAnimation;
  late AnimationController breathingController;
  late Animation<double> breathingAnimation;

  late bool _isVoted;

  @override
  void initState() {
    _isVoted = false;
    expandingController = new AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    expandingAnimation =
        new Tween(begin: 0.0, end: _maxRadius).animate(expandingController)
          ..addListener(() => setState(() => {}))
          ..addStatusListener((status) {
            switch (status) {
              case AnimationStatus.dismissed:
                widget.onRemove(widget.pointer);
                break;
              case AnimationStatus.forward:
                break;
              case AnimationStatus.reverse:
                break;
              case AnimationStatus.completed:
                widget.onReady(widget.pointer, true);
                break;
            }
          });
    shrinkingController = new AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    shrinkingAnimation = new Tween(begin: _maxBackgroud, end: _maxRadius + 50.0)
        .animate(shrinkingController)
          ..addListener(() => setState(() {}))
          ..addStatusListener((status) {
            switch (status) {
              case AnimationStatus.dismissed:
                break;
              case AnimationStatus.forward:
                print("gooooooooo!");
                break;
              case AnimationStatus.reverse:
                break;
              case AnimationStatus.completed:
                break;
            }
          });
    breathingController = new AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 550),
    );
    breathingAnimation = new Tween(begin: 0.95, end: 1.10)
        .animate(breathingController)
          ..addListener(() => setState(() => {}));

    breathingController.repeat(reverse: true);
    expandingController.forward();

    bus.on(widget.pointer, _voted); // 订阅，提供回调函数
    bus.on(removeEvent + widget.pointer.toString(),
        onRemoveSignalRecv); // 订阅，提供回调函数
  }

  // 收到即将释放的信号的回调函数
  void onRemoveSignalRecv(pointer) {
    print("remove signal recv!");
    if (widget.pointer == pointer) {
      expandingController.reverse();
    }
    if (_isVoted) {
      shrinkingController.reverse();
    }
  }

  @override
  void dispose() {
    expandingController.dispose();
    breathingController.dispose();
    shrinkingController.dispose();
    bus.off(widget.color); // 关闭订阅
    bus.off(removeEvent + widget.pointer.toString()); // 关闭订阅
    super.dispose();
    print("${this} ${widget.pointer} disposed!");
  }

  @override
  Widget build(BuildContext context) {
    var _value = expandingAnimation.value * breathingAnimation.value;
    var _proportion = expandingAnimation.value / _maxRadius;
    // print("_isVoted:${_isVoted}");
    var stack = Stack(
      children: [
        Mybackground(
          top: widget.y,
          left: widget.x,
          radius: shrinkingAnimation.value,
          color: widget.color,
          offset: shrinkingAnimation.value,
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
    return stack;
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

class _MyCircleState extends State<MyCircle>
    with SingleTickerProviderStateMixin {
  late AnimationController rotateController;
  late Animation<double> rotateAnimation;
  @override
  void initState() {
    rotateController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 5000),
    );
    rotateAnimation = Tween(begin: 0.0, end: 3.0).animate(rotateController)
      ..addListener(() => setState(() => {}));
    rotateController.repeat();
  }

  @override
  void dispose() {
    rotateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: widget.top - 16.0,
      left: widget.left - 16.0,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CircleAvatar(
            radius: widget.radius,
            backgroundColor: widget.color!.withOpacity(0.70),
          ),
          RotationTransition(
            turns: rotateAnimation,
            child: SizedBox(
              width: (widget.radius + 16.0) * 2,
              height: (widget.radius + 16.0) * 2,
              child: CircularProgressIndicator(
                color: widget.color,
                value: widget.value,
                backgroundColor: widget.color!.withAlpha(128).withOpacity(0.50),
                strokeWidth: 9.0 * widget.radius / 50.0,
              ),
            ),
          ),
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
