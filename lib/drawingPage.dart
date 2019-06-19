import 'dart:ui';

import 'package:flutter/material.dart';
import './drawingPainter.dart';
import './drawingLogic.dart';
import 'package:flutter/scheduler.dart';

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
  bool visibleColors = false;
  bool show = true;
  bool hide = false;
  @override
  void dispose() {
    _controllerFigure.dispose();
    _controllerColor.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _controllerFigure =
        AnimationController(vsync: this, duration: Duration(milliseconds: 300));
    _controllerColor =
        AnimationController(vsync: this, duration: Duration(milliseconds: 300));
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
            showingColors = false;
          }
          showingOptions
              ? _controllerFigure.reverse()
              : _controllerFigure.forward();
          showingOptions = !showingOptions;
        }),
        buildFlatButton(
          Icon(Icons.color_lens),
          'color',
          () {
            if (showingOptions) {
              showingOptions = false;
            }
            if (!showingColors){
              showingColors = true;
              show = true;
            } else{
              visibleColors = false;
              hide= true;
            }
          },
        )
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
            setState(setStateAction);

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

  Widget buildFlatButtonOpacity(Icon icon, String tag, Function action,
      bool condition) {
    return Container(
      width: 55,
      height: 70,
      //alignment: FractionalOffset.topCenter,
      child: AnimatedOpacity(
        opacity: condition ? 1.0 : 0.0,
        curve: Curves.linear,
        duration: Duration(milliseconds: 400),
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
        buildFlatButtonOpacity(
            Icon(
              Icons.radio_button_unchecked,
              semanticLabel: "circle",
            ),
            'circle',
            () => logic.output = DrawArtifactType.Circle,showingOptions),
        buildFlatButtonOpacity(Icon(Icons.border_color), 'line',
            () => logic.output = DrawArtifactType.Line, showingOptions),
        buildFlatButtonOpacity(Icon(Icons.crop_square), 'rect',
            () => logic.output = DrawArtifactType.Rectangle,showingOptions),
        buildFlatButtonOpacity(Icon(Icons.create), 'draw',
            () => logic.output = DrawArtifactType.Draw,showingOptions)
      ],
    );
  }

  Widget buildColorSelection() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        buildFlatButtonOpacity(Icon(Icons.format_paint, color: Colors.red),
            'color_red', () => logic.selectedColor = Colors.red,
            visibleColors),
        buildFlatButtonOpacity(Icon(Icons.format_paint, color: Colors.green),
            'color_green', () => logic.selectedColor = Colors.green,
            visibleColors),
        buildFlatButtonOpacity(Icon(Icons.format_paint, color: Colors.blue),
            'color_blue', () => logic.selectedColor = Colors.blue,
            visibleColors),
        buildFlatButtonOpacity(Icon(Icons.format_paint, color: Colors.yellow),
            'color_yellow', () => logic.selectedColor = Colors.yellow,
            visibleColors),
        buildFlatButtonOpacity(Icon(Icons.format_paint, color: Colors.black),
            'color_black', () => logic.selectedColor = Colors.black,
            visibleColors)
      ],
    );
  }

  Widget colorSelectionWidget() {
    if (showingColors) {
      return buildColorSelection();
    } else {
      return SizedBox();
    }
  }

  @override
  Widget build(BuildContext context) {
    RenderBox renderBox = context.findRenderObject();
    if (SchedulerBinding.instance.schedulerPhase ==
        SchedulerPhase.persistentCallbacks) {
      SchedulerBinding.instance.addPostFrameCallback((_) {
        if (show && showingColors) {
          setState(() {
            visibleColors = true;
            show = false;
             });
            } else if (hide && showingColors){
              Future.delayed(const Duration(seconds: 1), () => setState(() {
                showingColors = false;
                hide = false;
              })
              );
            }   
      });
    }
    return Scaffold(
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            buildOptionsBar(),
            colorSelectionWidget(),
            buildToolBar(),
          ],
        ),
      ),
      body: GestureDetector(
        onPanUpdate: (details) {
          setState(() {
            switch (logic.output) {
              case DrawArtifactType.Draw:
                (logic.currentFigure as DisplaySkribblesClass).points.add(
                    DrawingPoint(
                        point:
                            renderBox.globalToLocal(details.globalPosition)));
                break;
              case DrawArtifactType.Line:
                logic.currentFigure.finish = (DrawingPoint(
                    point: renderBox.globalToLocal(details.globalPosition)));
                break;
              case DrawArtifactType.Rectangle:
                logic.currentFigure.finish = (DrawingPoint(
                    point: renderBox.globalToLocal(details.globalPosition)));
                break;
              case DrawArtifactType.Circle:
                logic.currentFigure.finish = (DrawingPoint(
                    point: renderBox.globalToLocal(details.globalPosition)));
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
                    paint: logic.selectedPaint(),
                    points: [
                      DrawingPoint(
                        point: renderBox.globalToLocal(details.globalPosition),
                      )
                    ],
                    figure: DrawArtifactType.Draw);
                break;
              case DrawArtifactType.Line:
                logic.currentFigure = DisplayLineClass(
                    paint: logic.selectedPaint(),
                    start: DrawingPoint(
                      point: renderBox.globalToLocal(details.globalPosition),
                    ),
                    figure: DrawArtifactType.Line);
                break;
              case DrawArtifactType.Rectangle:
                logic.currentFigure = DisplayRectangleClass(
                    paint: logic.selectedPaint(),
                    start: DrawingPoint(
                      point: renderBox.globalToLocal(details.globalPosition),
                    ),
                    figure: DrawArtifactType.Rectangle);
                break;
              case DrawArtifactType.Circle:
                logic.currentFigure = DisplayCircleClass(
                    paint: logic.selectedPaint(),
                    start: DrawingPoint(
                      point: renderBox.globalToLocal(details.globalPosition),
                    ),
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
