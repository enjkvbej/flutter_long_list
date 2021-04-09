import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_long_list/flutter_long_list.dart';
import '../api/http.dart';
import '../model/feed_item.dart';

class GridViewDemo extends StatefulWidget {
  GridViewDemo({Key key}) : super(key: key);

  @override
  _GridViewDemoState createState() => _GridViewDemoState();
}

class _GridViewDemoState extends State<GridViewDemo> {
  String id = 'grid_view';
  ScrollToIndexController scrollController = ScrollToIndexController();

  @override
  initState() {
    _init();
    super.initState();
  }

  _init() async{
    LongListProvider<FeedItem> longListProvider =
      Provider.of<LongListProvider<FeedItem>>(context, listen: false);
    longListProvider.init(
      id: id,
      pageSize: 5,
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
      body: LongList<FeedItem>(
        id: id,
        controller: scrollController,
        exposureCallback: (LongListProvider<FeedItem> provider, List<ToExposureItem> exposureList) {
          exposureList.forEach((item) {
            print('上报数据：${provider.list[id][item.index].color} ${item.index} ${item.time}');
          });
        },
        cacheExtent: double.infinity,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 10.0,
          mainAxisSpacing: 10.0,
        ),
        padding: EdgeInsets.only(left: 10, right: 10),
        mode: LongListMode.grid,
        itemWidget: itemWidget,
      )
    );
  }

  Widget itemWidget(BuildContext context, LongListProvider<FeedItem> provider, String id, int index, FeedItem data) {
    print('rebuild${index}');
    return Container(
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
              'delete${index}'
            )
          ),
          GestureDetector(
            onTap: () {
              scrollController.scrollToIndex(provider, id, 7);
            },
            child: Text(
              'scrollTo'
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