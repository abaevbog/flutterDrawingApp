import 'dart:io';
import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';

class DrawingPoint {
  Offset point;
  DrawArtifactType output;
  DrawingPoint({this.point});
}

class DisplayFigure {
  Paint paint;
  DrawArtifactType figure;
  DrawingPoint start;
  DrawingPoint finish;
  DisplayFigure({this.start, this.finish, this.figure, this.paint});
  factory DisplayFigure.from(DisplayFigure other) {
    switch (other.figure) {
      case DrawArtifactType.Draw:
        DisplaySkribblesClass figure = (other as DisplaySkribblesClass);
        return DisplaySkribblesClass(points:figure.points,figure: other.figure, paint: other.paint);
        break;
      case DrawArtifactType.Line:
        return DisplayLineClass(
            start: other.start, finish: other.finish, figure: other.figure,paint: other.paint);
        break;
      case DrawArtifactType.Rectangle:
        return DisplayRectangleClass(
            start: other.start, finish: other.finish, figure: other.figure,paint: other.paint);
        break;
      case DrawArtifactType.Circle:
        return DisplayCircleClass(
            start: other.start, finish: other.finish, figure: other.figure,paint: other.paint);
        break;
    }
    return null;
  }

  void clear() {
    start = null;
    finish = null;
    figure = null;
  }

  void setFigureType(DrawArtifactType newFigure) {
    figure = newFigure;
  }

  void draw(Canvas canvas) {
    switch (figure) {
      case DrawArtifactType.Draw:
        DisplaySkribblesClass skribbles = (this as DisplaySkribblesClass);
        skribbles.drawing(canvas);
        break;
      case DrawArtifactType.Line:
        DisplayLineClass line = (this as DisplayLineClass);
        line.drawing(canvas);
        break;
      case DrawArtifactType.Rectangle:
        DisplayRectangleClass rect = (this as DisplayRectangleClass);
        rect.drawing(canvas);
        break;
      case DrawArtifactType.Circle:
        DisplayCircleClass circle = (this as DisplayCircleClass);
        circle.drawing(canvas);
        break;
    }
  }
}

class DisplayLineClass extends DisplayFigure {
  DisplayLineClass(
      {DrawingPoint start, DrawingPoint finish, DrawArtifactType figure, Paint paint})
      : super(start: start, finish: finish, figure: figure, paint:paint);

  void drawing(Canvas canvas) {
    canvas.drawCircle(start.point, 3, paint);
    canvas.drawCircle(finish.point, 3, paint);
    canvas.drawLine(start.point, finish.point, paint);
  }
}

class DisplayRectangleClass extends DisplayFigure {
  DisplayRectangleClass({start, finish, figure, Paint paint})
      : super(start: start, finish: finish, figure: figure, paint:paint);

  void drawing(Canvas canvas) {
    canvas.drawLine(
        start.point, Offset(finish.point.dx, start.point.dy), paint);
    canvas.drawLine(
        start.point, Offset(start.point.dx, finish.point.dy), paint);
    canvas.drawLine(
        finish.point, Offset(finish.point.dx, start.point.dy), paint);
    canvas.drawLine(
        finish.point, Offset(start.point.dx, finish.point.dy), paint);
  }
}


class DisplayCircleClass extends DisplayFigure{
  DisplayCircleClass({start, finish, figure, Paint paint})
      : super(start: start, finish: finish, figure: figure, paint:paint);  

  void drawing(Canvas canvas){

    canvas.drawCircle(start.point, distance(start, finish), paint);
  }    

  double distance(DrawingPoint one, DrawingPoint two){
    return sqrt(pow((two.point.dx - one.point.dx),2) + 
      pow((two.point.dy - one.point.dy),2) );
  }

}

class DisplaySkribblesClass extends DisplayFigure{
  List<DrawingPoint> points;

  DisplaySkribblesClass({this.points, figure, Paint paint})
    : super(start: points[0], finish: points.last, figure: figure, paint: paint); 

    void drawing(Canvas canvas){
      List<Offset> lst = [];
      for(int i = 0; i < points.length;i++){
        lst.add(points[i].point);
      }
      canvas.drawPoints(PointMode.polygon, lst, paint);
      
    }
}


enum SelectedMode { StrokeWidth, Opacity, Color, Output }
enum DrawArtifactType { Draw, Line, Rectangle, Circle }
enum Line { noPoints, onePoint, twoPoints }

class DrawingLogic {
  Color selectedColor = Colors.black;
  double strokeWidth = 3.0;
  bool showBottomList = false;
  double opacity = 1.0;
  StrokeCap strokeCap = (Platform.isAndroid) ? StrokeCap.butt : StrokeCap.round;
  SelectedMode selectedMode = SelectedMode.StrokeWidth;
  DrawArtifactType output = DrawArtifactType.Draw;
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

  Paint selectedPaint() {
    print(selectedColor);
    return Paint()
      ..style = PaintingStyle.stroke
      ..color = selectedColor
      ..strokeWidth = 3;
  }

  static int itemCount = 0;
  static get count{
    itemCount+=1;
    return itemCount;
  }

  void undo(){
    try{
      drawnFigures.removeLast();
    } catch(e){

    }
  }

}
