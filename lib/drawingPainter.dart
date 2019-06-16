import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import './drawingLogic.dart';
import 'dart:async';
import 'dart:ui' as ui;
import 'package:path_provider/path_provider.dart';
import './main.dart';

class DrawingPainter extends CustomPainter {
  DrawingPainter(
      {this.pointsList,
      this.mode,
      this.drawnFigures,
      this.currentFigure,
      this.createImage = false,
      this.length,
      this.context});
  List<DrawingPoint> pointsList;
  DisplayFigure currentFigure;
  List<Offset> offsetPoints = List();
  DrawArtifactType mode;
  List<DisplayFigure> drawnFigures;
  bool createImage;
  BuildContext context;
  int length;

  Future<ui.Image> get save async {
    ui.PictureRecorder recorder = ui.PictureRecorder();
    Canvas canvas = Canvas(recorder);
    DrawingPainter painter =
        DrawingPainter(pointsList: pointsList, drawnFigures: drawnFigures);
    var size = MediaQueryData.fromWindow(ui.window).size;
    painter.paint(canvas, size);
    final res = await recorder
        .endRecording()
        .toImage(size.width.floor(), size.height.floor());
    return res;
  }

  @override
  void paint(Canvas canvas, Size size) async {
    if (createImage) {
      final directory = await getApplicationDocumentsDirectory();
     // if (FileSystemEntity.typeSync('${directory.path}/new_img.png') ==
       //   FileSystemEntityType.notFound) {
        ui.Image pic = await save;
        final byteData = await pic.toByteData(format: ui.ImageByteFormat.png);
        final pngBytes = byteData.buffer.asUint8List();
        final file = File('${directory.path}/img_$length.png');
        file.writeAsBytesSync(pngBytes);
        int count = DrawingLogic.count;
        Drawing newDrawing =
            Drawing(path: '${directory.path}/img_$length.png', title: "Item $length");
        
        try {
          print("in try");
          
          if(Navigator.canPop(context)) {
            print("can pop");
            Navigator.pop(context, newDrawing);
            }
        } catch (e) {
          print("Exception: future completed");
        }
      //}
      return;
    }

    for (int i = 0; i < pointsList.length - 1; i++) {
      if (pointsList[i] != null && pointsList[i + 1] != null) {
        canvas.drawLine(pointsList[i].point, pointsList[i + 1].point,
            pointsList[i].paint);
      } else if (pointsList[i] != null && pointsList[i + 1] == null) {
        offsetPoints.clear();
        offsetPoints.add(pointsList[i].point);
        offsetPoints.add(Offset(
            pointsList[i].point.dx + 0.1, pointsList[i].point.dy + 0.1));
        canvas.drawPoints(
            ui.PointMode.points, offsetPoints, pointsList[i].paint);
      }
    }
    for (int i = 0; i < drawnFigures.length; i++) {
      drawnFigures[i].draw(canvas, DrawingLogic.defaultPaint);
    }
    if (currentFigure != null) {
      if (currentFigure.start != null && currentFigure.finish != null) {
        currentFigure.draw(canvas, DrawingLogic.defaultPaint);
      }
    }
  }

  @override
  bool shouldRepaint(DrawingPainter oldDelegate) => true;
}
