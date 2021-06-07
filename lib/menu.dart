import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

typedef DataChangeCallBack(int mode, int targetNum);

void main() {
  runApp(new MaterialApp(
    title: "chwazi",
    home: new Scaffold(
      body: Stack(
        children: [
          Container(
            color: Colors.black,
          ),
          Center(
            child: Menu(
              onDataChange: (mode, targetNum) => {},
            ),
          ),
        ],
      ),
    ),
  ));
}

class Menu extends StatefulWidget {
  Menu({
    required this.onDataChange,
  }) : super(key: ObjectKey("menu"));
  DataChangeCallBack onDataChange;
  @override
  _MenuState createState() => _MenuState();
}

class _MenuState extends State<Menu> {
  int _targetNum = 1;

  @override
  Widget build(BuildContext context) {
    Center center = Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                onPressed: () => {setState(() => --_targetNum)},
                icon: Icon(
                  Icons.exposure_minus_1,
                  color: Colors.white,
                ),
              ),
              Text(
                _targetNum.toString(),
                style: TextStyle(
                  color: Colors.blue,
                  fontSize: 14.0,
                  height: 1.2,
                  fontFamily: "Curier",
                ),
              ),
              IconButton(
                onPressed: () => {setState(() => ++_targetNum)},
                icon: Icon(
                  Icons.exposure_plus_1,
                  color: Colors.white,
                ),
              ),
            ],
          )
        ],
      ),
    );
    return center;
    return Overlay(
      key: ObjectKey(this),
      initialEntries: [
        OverlayEntry(builder: (context) => center),
      ],
    );
  }
}
