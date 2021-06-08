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
      duration: const Duration(milliseconds: 500),
    );
    expandingAnimation =
        new Tween(begin: 0.0, end: _maxRadius).animate(expandingController)
          ..addListener(() => setState(() => {}))
          ..addStatusListener((status) {
            switch (status) {
              case AnimationStatus.dismissed:
                widget.onRemove(widget.pointer);
                print("${widget.pointer} end!");
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
    if (_isVoted && widget.pointer == pointer) {
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
          top: widget.y,
          left: widget.x,
          radius: expandingAnimation.value,
          color: widget.color,
          factor: breathingAnimation.value,
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
    required this.top,
    required this.left,
    required this.factor,
  });

  double radius = 1.0;
  Color? color = Colors.red;
  double top;
  double left;
  double factor;

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
    var val = widget.radius * widget.factor;
    var muli = 2.4;
    return Positioned(
      top: widget.top - val * muli / 2,
      left: widget.left - val * muli / 2,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: val * 0.9 * 2,
            height: val * 0.9 * 2,
            child: CircleAvatar(
              // radius: val * 0.9,
              backgroundColor: widget.color!.withOpacity(0.70),
            ),
          ),
          RotationTransition(
            turns: rotateAnimation,
            child: SizedBox(
              width: val * muli,
              height: val * muli,
              child: CircularProgressIndicator(
                color: widget.color,
                value: widget.radius / 45.0,
                backgroundColor: widget.color!.withAlpha(128).withOpacity(0.50),
                strokeWidth: val * muli / 2 - val - 2.0,
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
