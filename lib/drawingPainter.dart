import 'dart:io';
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import './drawingLogic.dart';
import 'dart:async';
import 'dart:ui' as ui;
import 'package:path_provider/path_provider.dart';
import './main.dart';

class DrawingPainter extends CustomPainter {
  DrawingPainter(
      {this.drawnFigures,
      this.currentFigure,
      this.createImage = false,
      this.length,
      this.context});
  DisplayFigure currentFigure;
  List<DisplayFigure> drawnFigures;
  bool createImage;
  BuildContext context;
  int length;

  Future<ui.Image> get save async {
    ui.PictureRecorder recorder = ui.PictureRecorder();
    Canvas canvas = Canvas(recorder);
    DrawingPainter painter =
        DrawingPainter(drawnFigures: drawnFigures);
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
      return;
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
