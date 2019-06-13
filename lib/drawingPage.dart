import 'dart:ui';
import 'package:flutter/material.dart';
import './drawingPainter.dart';
import './drawingLogic.dart';

class Draw extends StatefulWidget {
  final int length;
  Draw(this.length);
  @override
  _DrawState createState() => _DrawState();
}

class _DrawState extends State<Draw> {
  DrawingLogic logic = DrawingLogic();
  Widget buildToolBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
            IconButton(
                icon: Icon(Icons.save),
                onPressed: () {
                  setState(() {
                    logic.willSave = true;
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
              icon: Icon(Icons.radio_button_unchecked),
              onPressed: () {
                setState(() {
                  logic.output = SelectedOutput.Circle;
                });
              }),
            IconButton(
              icon: Icon(Icons.linear_scale),
              onPressed: () {
                setState(() {
                  logic.output = SelectedOutput.Line;
                });
              }),
            IconButton(
              icon: Icon(Icons.crop_square),
              onPressed: () {
                setState(() {
                  logic.output = SelectedOutput.Rectangle;
                });
              }),
            IconButton(
              icon: Icon(Icons.all_inclusive),
              onPressed: () {
                setState(() {
                  logic.output = SelectedOutput.Draw;
                });
              }),
          ] ,
    );
  }


  @override
  Widget build(BuildContext context) {
    print(logic.output);
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
                ],
              ),
            )),
      ),
      body: GestureDetector(
        onPanUpdate: (details) {
          setState(() {
            RenderBox renderBox = context.findRenderObject();
            switch (logic.output) {
              case SelectedOutput.Draw:
                logic.points.add(DrawingPoints(
                    points: renderBox.globalToLocal(details.globalPosition),
                    paint: DrawingLogic.defaultPaint));
                break;
              case SelectedOutput.Line:
                logic.currentFigure.finish = (DrawingPoints(
                    points: renderBox.globalToLocal(details.globalPosition),
                    paint: DrawingLogic.defaultPaint));
                break;
              case SelectedOutput.Rectangle:
                logic.currentFigure.finish = (DrawingPoints(
                    points: renderBox.globalToLocal(details.globalPosition),
                    paint: DrawingLogic.defaultPaint));
                break;
              case SelectedOutput.Circle:
                logic.currentFigure.finish = (DrawingPoints(
                    points: renderBox.globalToLocal(details.globalPosition),
                    paint: DrawingLogic.defaultPaint));
                break;
            }
          });
        },
        onPanStart: (details) {
          setState(() {
            RenderBox renderBox = context.findRenderObject();
            switch (logic.output) {
              case SelectedOutput.Draw:
                logic.points.add(DrawingPoints(
                    points: renderBox.globalToLocal(details.globalPosition),
                    paint: DrawingLogic.defaultPaint));
                break;
              case SelectedOutput.Line:
                logic.currentFigure = DisplayLineClass(
                    start: DrawingPoints(
                        points: renderBox.globalToLocal(details.globalPosition),
                        paint: DrawingLogic.defaultPaint),
                    figure: SelectedOutput.Line);
                break;
              case SelectedOutput.Rectangle:
                logic.currentFigure = DisplayRectangleClass(
                    start: DrawingPoints(
                        points: renderBox.globalToLocal(details.globalPosition),
                        paint: DrawingLogic.defaultPaint),
                    figure: SelectedOutput.Rectangle);
                break;
              case SelectedOutput.Circle:
                logic.currentFigure = DisplayCircleClass(
                    start: DrawingPoints(
                        points: renderBox.globalToLocal(details.globalPosition),
                        paint: DrawingLogic.defaultPaint),
                    figure: SelectedOutput.Circle);
                break;
            }
          });
        },
        onPanEnd: (details) {
          setState(() {
            if (logic.output == SelectedOutput.Draw) {
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
              createImage: logic.willSave,
              length: widget.length,
              context: context),
        ),
      ),
    );
  }
}
