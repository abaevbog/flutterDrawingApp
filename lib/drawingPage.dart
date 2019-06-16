import 'dart:ui';

import 'package:flutter/material.dart';
import './drawingPainter.dart';
import './drawingLogic.dart';

class Draw extends StatefulWidget {
  int length;
  Draw(this.length);
  @override
  _DrawState createState() => _DrawState();
}

class _DrawState extends State<Draw> with TickerProviderStateMixin {
  AnimationController _controller;
  DrawingLogic logic = DrawingLogic();
  bool showingOptions = false;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: Duration(milliseconds: 300));
  }

  Widget buildToolBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        IconButton(
            icon: Icon(Icons.save),
            onPressed: () {
              setState(() {
                logic.willSave = true;
                //Navigator.of(context).pop();
              });
            }),
        IconButton(
            icon: Icon(Icons.clear),
            onPressed: () {
              setState(() {
                logic.points.clear();
                logic.currentFigure.clear();
                logic.drawnFigures.clear();
              });
            }),
        IconButton(
            icon: Icon(Icons.expand_less),
            onPressed: () {
              setState(() {
                showingOptions ? _controller.forward() : _controller.reverse();
              });
            }),
      ],
    );
  }

  Widget buildOptionsBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        IconButton(
            icon: Icon(Icons.radio_button_unchecked),
            onPressed: () {
              setState(() {
                logic.output = DrawArtifactType.Circle;
              });
            }),
        IconButton(
            icon: Icon(Icons.linear_scale),
            onPressed: () {
              setState(() {
                logic.output = DrawArtifactType.Line;
              });
            }),
        IconButton(
            icon: Icon(Icons.crop_square),
            onPressed: () {
              setState(() {
                logic.output = DrawArtifactType.Rectangle;
              });
            }),
        IconButton(
            icon: Icon(Icons.all_inclusive),
            onPressed: () {
              setState(() {
                logic.output = DrawArtifactType.Draw;
              });
            }),
      ],
    );
  }

  Widget optionsWithAnimations() {
    return FadeTransition(
        opacity: CurvedAnimation(
          curve: Interval(0, 1.0, curve: Curves.easeIn),
          parent: _controller,
        ),
        child: buildOptionsBar());
  }

  @override
  Widget build(BuildContext context) {
    RenderBox renderBox = context.findRenderObject();
    return Scaffold(
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
            padding: const EdgeInsets.only(left: 8.0, right: 8.0),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(50.0),
                color: logic.toolBarColor),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  buildToolBar(),
                  optionsWithAnimations(),
                ],
              ),
            )),
      ),
      body: GestureDetector(
        onPanUpdate: (details) {
          setState(() {
            switch (logic.output) {
              case DrawArtifactType.Draw:
                logic.points.add(DrawingPoint(
                    point: renderBox.globalToLocal(details.globalPosition),
                    paint: DrawingLogic.defaultPaint));
                break;
              case DrawArtifactType.Line:
                logic.currentFigure.finish = (DrawingPoint(
                    point: renderBox.globalToLocal(details.globalPosition),
                    paint: DrawingLogic.defaultPaint));
                break;
              case DrawArtifactType.Rectangle:
                logic.currentFigure.finish = (DrawingPoint(
                    point: renderBox.globalToLocal(details.globalPosition),
                    paint: DrawingLogic.defaultPaint));
                break;
              case DrawArtifactType.Circle:
                logic.currentFigure.finish = (DrawingPoint(
                    point: renderBox.globalToLocal(details.globalPosition),
                    paint: DrawingLogic.defaultPaint));
                break;
            }
          });
        },
        onPanStart: (details) {
          setState(() {
            RenderBox renderBox = context.findRenderObject();
            switch (logic.output) {
              case DrawArtifactType.Draw:
                logic.points.add(DrawingPoint(
                    point: renderBox.globalToLocal(details.globalPosition),
                    paint: DrawingLogic.defaultPaint));
                break;
              case DrawArtifactType.Line:
                logic.currentFigure = DisplayLineClass(
                    start: DrawingPoint(
                        point: renderBox.globalToLocal(details.globalPosition),
                        paint: DrawingLogic.defaultPaint),
                    figure: DrawArtifactType.Line);
                break;
              case DrawArtifactType.Rectangle:
                logic.currentFigure = DisplayRectangleClass(
                    start: DrawingPoint(
                        point: renderBox.globalToLocal(details.globalPosition),
                        paint: DrawingLogic.defaultPaint),
                    figure: DrawArtifactType.Rectangle);
                break;
              case DrawArtifactType.Circle:
                logic.currentFigure = DisplayCircleClass(
                    start: DrawingPoint(
                        point: renderBox.globalToLocal(details.globalPosition),
                        paint: DrawingLogic.defaultPaint),
                    figure: DrawArtifactType.Circle);
                break;
            }
          });
        },
        onPanEnd: (details) {
          setState(() {
            if (logic.output == DrawArtifactType.Draw) {
              logic.points.add(null);
            } else if (logic.currentFigure.finish != null) {
              logic.drawnFigures.add(DisplayFigure.from(logic.currentFigure));
              logic.currentFigure.clear();
            }
          });
        },
        child: CustomPaint(
          size: Size.infinite,
          painter: DrawingPainter(
              pointsList: logic.points,
              mode: logic.output,
              drawnFigures: logic.drawnFigures,
              currentFigure: logic.currentFigure,
              createImage: logic.willSave),
        ),
      ),
    );
  }
}
