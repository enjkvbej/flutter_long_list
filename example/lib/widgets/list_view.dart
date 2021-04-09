import 'package:example/api/http.dart';
import 'package:example/model/feed_item.dart';
import 'package:example/widgets/list_view/index.dart';
import 'package:example/widgets/list_view/like.dart';
import 'package:flutter/material.dart';
import 'package:flutter_long_list/flutter_long_list.dart';
import 'package:provider/provider.dart';


class ListViewDemo extends StatefulWidget {
  ListViewDemo({Key key}) : super(key: key);

  @override
  _ListViewDemoState createState() => _ListViewDemoState();
}

class _ListViewDemoState extends State<ListViewDemo>  with SingleTickerProviderStateMixin{
  TabController _tabController; //需要定义一个Controller
  List tabs = ["发现", "喜欢"];

  @override
  initState() {
    _init();
    _tabController = TabController(length: tabs.length, vsync: this);
    // _tabController.addListener((){  
    //   switch(_tabController.index){
    //     case 1:
    //       _tabController.animateTo()
    //       break;
    //     case 2: ... ;   
    //   }
    // });
    super.initState();
  }

  _init() async{
    LongListProvider<FeedItem> longListProvider =
      Provider.of<LongListProvider<FeedItem>>(context, listen: false);
    longListProvider.init(
      id: 'list_like',
      pageSize: 10,
      request: (int offset) async => await _getList(offset),
    );
  }
  
  Future<LongListData> _getList(int offset) async{
    final result = await api(0, 10);
    if (result['list'] != null) {
      return LongListData(
        list: result['list'],
        total: result['total']
      );
    } else {
      return LongListData(error: 'error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        bottom: TabBar(
          controller: _tabController,
          tabs: tabs.map((e) => Tab(text: e)).toList()),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          ListIndex(),
          ListLike()
        ]
      ),
    );
  }
}