import 'package:flutter/material.dart';
import 'dart:io';
import './drawingPage.dart';

class Drawing {
  String path;
  String title;

  Drawing({this.path, this.title});
}

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Drawing'),
    );
  }
}

class DrawingPage extends StatelessWidget {
  final Drawing drawing;
  DrawingPage(this.drawing);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(drawing.title),
      ),
      body: Container(
        child: Image.file(File(drawing.path)),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<Drawing> drawings = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              Navigator.of(context)
                  .push(MaterialPageRoute(
                      builder: (BuildContext context) => Draw(drawings.length)))
                  .then((dynamic newDrawing) {
                print(newDrawing.title);
                setState(() {
                  drawings.add((newDrawing as Drawing));
                });
              });
            },
          )
        ],
      ),
      body: ListView.builder(
        itemBuilder: (BuildContext context, int index) {
          return Column(children: [
            Dismissible(
              key: Key(drawings[index].path),
              child: ListTile(
                leading: CircleAvatar(
                  child: Image.file(
                    File(drawings[index].path),
                  ),
                ),
                title: Text(drawings[index].title),
                onTap: () {
              Navigator.of(context)
                  .push(MaterialPageRoute(
                      builder: (BuildContext context) => DrawingPage(drawings[index] ))); 
                },
              ),
              onDismissed: (DismissDirection dir) {
                drawings.removeAt(index);
              },
            ),
            Divider(color: Colors.black),
          ]);
        },
        itemCount: drawings.length,
      ),
    );
  }
}
