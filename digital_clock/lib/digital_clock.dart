// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flutter_clock_helper/model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

enum _Element {
  section,
  background,
  text,
  shadowH1,
  shadowH2,
  shadowM1,
  shadowM2,
}

final _theme = {
  _Element.section: Color.fromARGB(255, 42, 27, 67),
  _Element.background: Color.fromARGB(255, 255, 80, 145),
  _Element.text: Color.fromARGB(255, 255, 245, 225),
  _Element.shadowH1: Color.fromARGB(255, 0, 146, 69),
  _Element.shadowH2: Color.fromARGB(255, 255, 154, 9),
  _Element.shadowM1: Color.fromARGB(255, 244, 54, 44),
  _Element.shadowM2: Color.fromARGB(255, 7, 132, 170),
};

/// A flat very basic digital clock with focus on readability from long distance
class DigitalClock extends StatefulWidget {
  const DigitalClock(this.model);

  final ClockModel model;

  @override
  _DigitalClockState createState() => _DigitalClockState();
}

class _DigitalClockState extends State<DigitalClock> {
  DateTime _dateTime = DateTime.now();
  Timer _timer;

  @override
  void initState() {
    super.initState();
    widget.model.addListener(_updateModel);
    _updateTime();
    _updateModel();
  }

  @override
  void didUpdateWidget(DigitalClock oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.model != oldWidget.model) {
      oldWidget.model.removeListener(_updateModel);
      widget.model.addListener(_updateModel);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    widget.model.removeListener(_updateModel);
    widget.model.dispose();
    super.dispose();
  }

  void _updateModel() {
    setState(() {
      // Cause the clock to rebuild when the model changes.
    });
  }

  void _updateTime() {
    setState(() {
      _dateTime = DateTime.now();
      _timer = Timer(
        Duration(minutes: 1) -
            Duration(seconds: _dateTime.second) -
            Duration(milliseconds: _dateTime.millisecond),
        _updateTime,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final hour =
        DateFormat(widget.model.is24HourFormat ? 'HH' : 'hh').format(_dateTime);
    final minute = DateFormat('mm').format(_dateTime);
    final fontSize = MediaQuery.of(context).size.width / 1.7;

    var h1Shadows = <Shadow>[];
    var h2Shadows = <Shadow>[];
    var m1Shadows = <Shadow>[];
    var m2Shadows = <Shadow>[];
    for (var i = 0; i <= fontSize.toInt(); i++) {
      h1Shadows.add(Shadow(
        color: _theme[_Element.shadowH1],
        offset: Offset(i.toDouble(), i.toDouble()),
      ));
      h2Shadows.add(Shadow(
        color: _theme[_Element.shadowH2],
        offset: Offset(i.toDouble(), i.toDouble()),
      ));
      m1Shadows.add(Shadow(
        color: _theme[_Element.shadowM1],
        offset: Offset(i.toDouble(), i.toDouble()),
      ));
      m2Shadows.add(Shadow(
        color: _theme[_Element.shadowM2],
        offset: Offset(i.toDouble(), i.toDouble()),
      ));
    }

    final h1Style = TextStyle(
        fontFamily: 'UbuntuMonoBold',
        fontSize: fontSize,
        color: _theme[_Element.text],
        shadows: h1Shadows,
        letterSpacing: -fontSize / 10);

    final h2Style = TextStyle(
        fontFamily: 'UbuntuMonoBold',
        fontSize: fontSize,
        color: _theme[_Element.text],
        shadows: h2Shadows,
        letterSpacing: -fontSize / 10);

    final m1Style = TextStyle(
      fontFamily: 'UbuntuMonoBold',
      fontSize: fontSize,
      color: _theme[_Element.text],
      shadows: m1Shadows,
    );

    final m2Style = TextStyle(
      fontFamily: 'UbuntuMonoBold',
      fontSize: fontSize,
      color: _theme[_Element.text],
      shadows: m2Shadows,
    );

    return Container(
      color: _theme[_Element.background],
      child: Stack(
        children: <Widget>[
          Positioned(
            left: 0,
            top: 0,
            child: ClipPath(
                clipper: LeftClipper(),
                child: Container(
                    color: _theme[_Element.section],
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height,
                    child: Stack(
                      children: <Widget>[
                        Positioned(
                            top: -30,
                            left: -30,
                            child: DefaultTextStyle(
                              style: h1Style,
                              child: Text(hour.substring(0, 1) + " "),
                            )),
                        Positioned(
                            top: -30,
                            left: -30,
                            child: DefaultTextStyle(
                              style: h2Style,
                              child: Text(" " + hour.substring(1)),
                            ))
                      ],
                    ))),
          ),
          Positioned(
              left: 10,
              top: 0,
              child: ClipPath(
                  clipper: RightClipper(),
                  child: Container(
                      color: _theme[_Element.section],
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height,
                      child: Stack(
                        children: <Widget>[
                          Positioned(
                              top: -30,
                              right: 0,
                              child: DefaultTextStyle(
                                style: m1Style,
                                child: Text(minute.substring(0, 1) + " "),
                              )),
                          Positioned(
                              top: -30,
                              right: 0,
                              child: DefaultTextStyle(
                                style: m2Style,
                                child: Text(" " + minute.substring(1)),
                              ))
                        ],
                      )))),
        ],
      ),
    );
  }
}

class LeftClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, 0);
    path.lineTo(size.width / 2, 0);
    path.lineTo(size.width / 2.75, size.height);
    path.lineTo(0, size.height);
    path.lineTo(0, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper oldClipper) {
    return false;
  }
}

class RightClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.moveTo(size.width / 2, 0);
    path.lineTo(size.width, 0);
    path.lineTo(size.width, size.height);
    path.lineTo(size.width / 2.75, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper oldClipper) {
    return false;
  }
}
