import 'package:example/pages/sliver_custom_view.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:example/pages/grid_view.dart';
import 'package:example/pages/sliver_grid_view.dart';
import 'package:example/pages/sliver_list_view.dart';
import 'package:example/pages/list_view.dart';

void main() {
  Provider.debugCheckInvalidValueType = null;
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FlutterLongList Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'FlutterLongList demo')
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
  @override
  Widget build(BuildContext _context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ListViewPage(),
            SizedBox(height: 20,),
            GridViewPage(),
            SizedBox(height: 20,),
            SliverGridViewPage(),
            SizedBox(height: 20,),
            SliverListViewPage(),
            SizedBox(height: 20,),
            SliverCustomViewPage(),
          ],
        ),
      ),
    );
  }
}
