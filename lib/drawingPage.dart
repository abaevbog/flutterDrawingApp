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
  AnimationController _controllerFigure;
  AnimationController _controllerColor;

  DrawingLogic logic = DrawingLogic();
  bool showingOptions = false;
  bool showingColors = false;

  @override
  void initState() {
    super.initState();
    _controllerFigure =
        AnimationController(vsync: this, duration: Duration(milliseconds: 300));
    _controllerColor =
        AnimationController(vsync: this, duration: Duration(milliseconds: 300));
  }

  TickerFuture other() {
    if (showingOptions) {
      _controllerFigure.reverse();
    }
    print("other");
    print(showingColors);
    return !showingColors ? _controllerColor.reverse() : _controllerColor.forward();
  }

  Widget buildToolBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        buildFlatButton(Icon(Icons.save), 'save', () => logic.willSave = true),
        buildFlatButton(Icon(Icons.clear), 'clear', () {
          logic.currentFigure.clear();
          logic.drawnFigures.clear();
        }),
        buildFlatButton(Icon(Icons.undo), 'undo', () {
          logic.undo();
        }),
        buildFlatButton(Icon(Icons.expand_less), 'options', () {
          if (showingColors) {
            _controllerColor.reverse();
            showingColors = false;
          }
          showingOptions
              ? _controllerFigure.reverse()
              : _controllerFigure.forward();
          showingOptions = !showingOptions;
        }),
        buildFlatButton(Icon(Icons.color_lens), 'color', () {
          if (showingOptions) {
            showingOptions = false;
          }
          showingColors = !showingColors;
          print("in state");
          print(showingColors);
        }, other: other)
      ],
    );
  }

  Widget buildFlatButton(Icon icon, String tag, Function setStateAction,
      {Function other}) {
    return Container(
      width: 55,
      height: 70,
      alignment: FractionalOffset.topCenter,
      child: FloatingActionButton(
          heroTag: tag,
          child: icon,
          onPressed: () {
            if (other != null) {
              print("Showing colors: $showingColors");
              if (showingColors){

              other().then(
                (_)=>setState(setStateAction)
              );
              } else {
                setState(setStateAction);
                other();
              }
              //setState(setStateAction);
            } else {
              print("A");
              setState(setStateAction);
            }
          }),
    );
  }

  Widget buildFlatButtonAnimated(Icon icon, String tag, Function action,
      {bool color = false}) {
    return Container(
      width: 55,
      height: 70,
      //alignment: FractionalOffset.topCenter,
      child: ScaleTransition(
        scale: CurvedAnimation(
            parent: color ? _controllerColor : _controllerFigure,
            curve: Interval(0.0, 1.0, curve: Curves.easeIn)),
        child: FloatingActionButton(
            heroTag: tag,
            child: icon,
            onPressed: () {
              setState(() {
                action();
              });
            }),
      ),
    );
  }

  Widget buildOptionsBar() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        buildFlatButtonAnimated(
            Icon(
              Icons.radio_button_unchecked,
              semanticLabel: "circle",
            ),
            'circle',
            () => logic.output = DrawArtifactType.Circle),
        buildFlatButtonAnimated(Icon(Icons.border_color), 'line',
            () => logic.output = DrawArtifactType.Line),
        buildFlatButtonAnimated(Icon(Icons.crop_square), 'rect',
            () => logic.output = DrawArtifactType.Rectangle),
        buildFlatButtonAnimated(Icon(Icons.create), 'draw',
            () => logic.output = DrawArtifactType.Draw)
      ],
    );
  }

  Widget buildColorSelection() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        buildFlatButtonAnimated(Icon(Icons.format_paint, color: Colors.red),
            'color_red', () => logic.selectedColor = Colors.red,
            color: true),
        buildFlatButtonAnimated(Icon(Icons.format_paint, color: Colors.green),
            'color_green', () => logic.selectedColor = Colors.green,
            color: true),
        buildFlatButtonAnimated(Icon(Icons.format_paint, color: Colors.blue),
            'color_blue', () => logic.selectedColor = Colors.blue,
            color: true),
        buildFlatButtonAnimated(Icon(Icons.format_paint, color: Colors.yellow),
            'color_yellow', () => logic.selectedColor = Colors.yellow,
            color: true),
        buildFlatButtonAnimated(Icon(Icons.format_paint, color: Colors.black),
            'color_black', () => logic.selectedColor = Colors.black,
            color: true)
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    RenderBox renderBox = context.findRenderObject();
    return Scaffold(
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            buildOptionsBar(),
            showingColors ? buildColorSelection() : SizedBox(),
            buildToolBar(),
          ],
        ),
      ),
      body: GestureDetector(
        onPanUpdate: (details) {
          setState(() {
            switch (logic.output) {
              case DrawArtifactType.Draw:
                (logic.currentFigure as DisplaySkribblesClass).points.add(DrawingPoint(
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
                logic.currentFigure = DisplaySkribblesClass(
                    points: [DrawingPoint(
                        point: renderBox.globalToLocal(details.globalPosition),
                        paint: DrawingLogic.defaultPaint)],
                    figure: DrawArtifactType.Draw);
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
            if (logic.currentFigure.finish != null) {
              logic.drawnFigures.add(DisplayFigure.from(logic.currentFigure));
              logic.currentFigure.clear();
            }
          });
        },
        child: CustomPaint(
          size: Size.infinite,
          painter: DrawingPainter(
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
