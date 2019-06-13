import 'dart:io';
import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';

class DrawingPoints {
  Paint paint;
  Offset points;
  SelectedOutput output;
  DrawingPoints({this.points, this.paint});
}

class DisplayFigure {
  SelectedOutput figure;
  DrawingPoints start;
  DrawingPoints finish;
  DisplayFigure({this.start, this.finish, this.figure});
  factory DisplayFigure.from(DisplayFigure other) {
    switch (other.figure) {
      case SelectedOutput.Draw:
        throw ("Constructor called on non-figure");
        break;
      case SelectedOutput.Line:
        return DisplayLineClass(
            start: other.start, finish: other.finish, figure: other.figure);
        break;
      case SelectedOutput.Rectangle:
        return DisplayRectangleClass(
            start: other.start, finish: other.finish, figure: other.figure);
        break;
      case SelectedOutput.Circle:
        return DisplayCircleClass(
            start: other.start, finish: other.finish, figure: other.figure);
        break;
    }
    return null;
  }

  void clear() {
    start = null;
    finish = null;
    figure = null;
  }

  void setFigureType(SelectedOutput newFigure) {
    figure = newFigure;
  }

  void draw(Canvas canvas, Paint paint) {
    switch (figure) {
      case SelectedOutput.Draw:
        throw ("Draw method called on non-figure");
        break;
      case SelectedOutput.Line:
        DisplayLineClass line = (this as DisplayLineClass);
        line.drawing(canvas, paint);
        break;
      case SelectedOutput.Rectangle:
        DisplayRectangleClass rect = (this as DisplayRectangleClass);
        rect.drawing(canvas, paint);
        break;
      case SelectedOutput.Circle:
        DisplayCircleClass circle = (this as DisplayCircleClass);
        circle.drawing(canvas, paint);
        break;
    }
  }
}

class DisplayLineClass extends DisplayFigure {
  DisplayLineClass(
      {DrawingPoints start, DrawingPoints finish, SelectedOutput figure})
      : super(start: start, finish: finish, figure: figure);

  void drawing(Canvas canvas, Paint paint) {
    canvas.drawCircle(start.points, 3, paint);
    canvas.drawCircle(finish.points, 3, paint);
    canvas.drawLine(start.points, finish.points, paint);
  }
}

class DisplayRectangleClass extends DisplayFigure {
  DisplayRectangleClass({start, finish, figure})
      : super(start: start, finish: finish, figure: figure);

  void drawing(Canvas canvas, Paint paint) {
    canvas.drawLine(
        start.points, Offset(finish.points.dx, start.points.dy), paint);
    canvas.drawLine(
        start.points, Offset(start.points.dx, finish.points.dy), paint);
    canvas.drawLine(
        finish.points, Offset(finish.points.dx, start.points.dy), paint);
    canvas.drawLine(
        finish.points, Offset(start.points.dx, finish.points.dy), paint);
  }
}


class DisplayCircleClass extends DisplayFigure{
  DisplayCircleClass({start, finish, figure})
      : super(start: start, finish: finish, figure: figure);  

  void drawing(Canvas canvas, Paint paint){

    canvas.drawCircle(start.points, distance(start, finish), paint);
  }    

  double distance(DrawingPoints one, DrawingPoints two){
    return sqrt(pow((two.points.dx - one.points.dx),2) + 
      pow((two.points.dy - one.points.dy),2) );
  }

}


enum SelectedMode { StrokeWidth, Opacity, Color, Output }
enum SelectedOutput { Draw, Line, Rectangle, Circle }
enum Line { noPoints, onePoint, twoPoints }

class DrawingLogic {
  Color selectedColor = Colors.black;
  Color pickerColor = Colors.black;
  double strokeWidth = 3.0;
  List<DrawingPoints> points = List();
  bool showBottomList = false;
  double opacity = 1.0;
  StrokeCap strokeCap = (Platform.isAndroid) ? StrokeCap.butt : StrokeCap.round;
  SelectedMode selectedMode = SelectedMode.StrokeWidth;
  List<Color> colors = [
    Colors.red,
    Colors.green,
    Colors.blue,
    Colors.amber,
    Colors.black
  ];
  SelectedOutput output = SelectedOutput.Draw;
  Color toolBarColor = Colors.greenAccent;
  List<DisplayFigure> drawnFigures = List();
  DisplayFigure currentFigure = DisplayFigure();
  bool willSave = false;

  static Paint defaultPaint = Paint()
    ..style = PaintingStyle.stroke  
    ..strokeCap = StrokeCap.round
    ..isAntiAlias = true
    ..color = Colors.black
    ..strokeWidth = 3;

  static int itemCount = 0;
  static get count{
    itemCount+=1;
    return itemCount;
  }

}
