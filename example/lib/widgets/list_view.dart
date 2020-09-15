import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_long_list/flutter_long_list.dart';
import '../api/http.dart';
import '../model/feed_item.dart';

class ListViewDemo extends StatefulWidget {
  ListViewDemo({Key key}) : super(key: key);

  @override
  _ListViewDemoState createState() => _ListViewDemoState();
}

class _ListViewDemoState extends State<ListViewDemo> {
  String id = 'list_view';
  ScrollController scrollController = new ScrollController();
  @override
  initState() {
    _init();
    // 初始化触发滚动 上报数据
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(Duration(milliseconds: 2000), () {
        scrollController.position.didEndScroll();
      });
    });
    super.initState();
  }

  _init() async{
    LongListProvider<FeedItem> longListProvider =
      Provider.of<LongListProvider<FeedItem>>(context, listen: false);
    longListProvider.init(
      id: id,
      pageSize: 10,
      request: (int offset) async => await _getList(offset),
    );
  }
  
  _getList(int offset) async{
    final result = await api(0, 10);
    print(result);
    if (result['list'] != null) {
      return {
        'list': result['list'],
        'total': result['total']
      };
    } else {
      return {
        'error': 'error'
      };
    }
  }

  @override
  Widget build(BuildContext context) {
    print(Provider.of<LongListStore>(context).list);
    return Scaffold(
      body: LongList<FeedItem>(
        padding: EdgeInsets.only(top: 100),
        id: id,
        controller: scrollController,
        itemWidget: itemWidget,
        exposureCallback: (LongListProvider<FeedItem> provider, List<ToExposureItem> exposureList) {
          exposureList.forEach((item) {
            print('上报数据：${provider.list[item.index].color} ${item.index} ${item.time}');
          });
        },
      )
    );
  }

  Widget itemWidget(BuildContext context, LongListProvider<FeedItem> provider, String id, int index, FeedItem data) {
    print('rebuild${index}');
    return  Container(
      height: 200,
      width: double.infinity,
      alignment: Alignment.center,
      color: data.color,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: () {
              provider.deleteItem(id, index);
            },
            child: Text(
              'delete${index}'
            )
          ),
          GestureDetector(
            onTap: () {
              data.like = !data.like;
              provider.changeItem(id, index, data);
            },
            child: Icon(
              data.like ? Icons.favorite : Icons.favorite_border
            )
          ),
        ],
      ),
    ); 
  }
}