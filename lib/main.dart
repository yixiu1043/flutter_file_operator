import 'package:flutter_file_operator/image_map.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

void main() {
  runApp(MyApp());
  var _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 0,
    ),
  );
  _logger.v('verbose message');
  _logger.d('debug message');
  _logger.i('info message');
  _logger.w('warning message');
  _logger.e('error message');
  _logger.wtf('wft message');
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
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
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Image.asset(ImageMap.BET_PANEL_1),
            Image.asset(ImageMap.BET_PANEL_2),
            Image.asset(ImageMap.BET_PANEL_3),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ),
    );
  }
}
