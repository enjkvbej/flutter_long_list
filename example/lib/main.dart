import 'package:example/pages/grid_view.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_long_list/flutter_long_list.dart';
import 'model/feed_item.dart';
import 'pages/list_view.dart';

void main() {
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
      home: ChangeNotifierProvider<LongListStore>(
        create: (_) => LongListStore(),
        child: MyHomePage(title: 'FlutterLongList demo')
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
            MaterialButton(
              onPressed: () {
                Navigator.push(
                  context,
                  PageRouteBuilder(pageBuilder: (BuildContext context1,
                      Animation animation, Animation secondaryAnimation) {
                    return ChangeNotifierProvider<LongListProvider<FeedItem>>(
                      create: (_) => LongListProvider<FeedItem>(store: context.read<LongListStore>()),
                      child: ListViewDemo()
                    );
                  }),
                );
              },
              color: Colors.grey,
              height: 40,
              child: Text(
                'ListView'
              )
            ),
            SizedBox(height: 20,),
            MaterialButton(
              onPressed: () {
                Navigator.push(
                  context,
                  PageRouteBuilder(pageBuilder: (BuildContext context1,
                      Animation animation, Animation secondaryAnimation) {
                    return ChangeNotifierProvider<LongListProvider<FeedItem>>(
                      create: (_) => LongListProvider<FeedItem>(store: context.read<LongListStore>()),
                      child: GridViewDemo(),
                    );
                  }),
                );
              },
              color: Colors.grey,
              height: 40,
              child: Text(
                'GridView'
              )
            )
          ],
        ),
      ),
    );
  }
}
