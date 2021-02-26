import 'package:example/api/http.dart';
import 'package:example/model/feed_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_long_list/flutter_long_list.dart';
import 'package:provider/provider.dart';

class ListIndex extends StatefulWidget {
  ListIndex({Key key}) : super(key: key);

  @override
  _ListIndexState createState() => _ListIndexState();
}

class _ListIndexState extends State<ListIndex> with AutomaticKeepAliveClientMixin{
  String id = 'list_view';
  ScrollToIndexController scrollController = ScrollToIndexController();
  @override
  bool get wantKeepAlive => true;

  @override
  initState() {
    _init();
    //初始化触发滚动 上报数据
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
    return Scaffold(
      body: LongList<FeedItem>(
        id: id,
        controller: scrollController,
        itemWidget: itemWidget,
        cacheExtent: double.infinity,
        exposureCallback: (LongListProvider<FeedItem> provider, List<ToExposureItem> exposureList) {
          exposureList.forEach((item) {
            print('上报数据：${provider.list[id][item.index].color} ${item.index} ${item.time}');
          });
        },
        nomore: (init) {
          return Container(
            alignment: Alignment.center,
            padding: EdgeInsets.only(top: 40, bottom: 40),
            child: Text(
              init ? '暂无相关内容...' : '已经到底了哦...',
              style: TextStyle(
                color: Colors.black.withOpacity(0.5),
                fontWeight: FontWeight.bold,
                fontSize: 13
              )
            )
          );
        }
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
              provider.removeItem(id, index);
            },
            child: Text(
              'delete ${data.text} ${index}'
            )
          ),
          GestureDetector(
            onTap: () {
              scrollController.scrollToIndex(provider, id, 6);
            },
            child: Text(
              'scrollTo'
            )
          ),
          GestureDetector(
            onTap: () {
              data.like = !data.like;
              provider.changeItem(id, index, data);
              if (data.like) {
                provider.addItem('list_like', 0, data);
              } else {
                provider.removeItem('list_like', 0);
              }
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