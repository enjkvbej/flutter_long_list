import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_long_list/flutter_long_list.dart';
import '../api/http.dart';
import '../model/feed_item.dart';

class SliverTabbarViewDemo extends StatefulWidget {
  SliverTabbarViewDemo({Key key}) : super(key: key);

  @override
  _SliverTabbarViewDemoState createState() => _SliverTabbarViewDemoState();
}

class _SliverTabbarViewDemoState extends State<SliverTabbarViewDemo> with SingleTickerProviderStateMixin {
  String id = 'sliver_tabbar';
  TabController tabController;
  @override
  initState() {
    _init();
    super.initState();
    this.tabController = TabController(length: 2, vsync: this);
  }

  _init() async{
    LongListProvider<FeedItem> longListProvider =
      Provider.of<LongListProvider<FeedItem>>(context, listen: false);
    longListProvider.init(
      id: id,
      pageSize: 10,
      request: (int offset) async => await _getList(offset),
    );
    longListProvider.init(
      id: 'test',
      pageSize: 10,
      request: (int offset) async => await _getList(offset),
    );
    // _scrollController = ScrollToIndexController()..addListener(_scrollListener);
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
      body: NestedScrollView(
        headerSliverBuilder: (context, bool) {
          return [
            SliverAppBar(
              pinned: true,
              elevation: 0,
              floating: true,
              expandedHeight: 250,
              flexibleSpace: FlexibleSpaceBar(
                title: Text('cshi'),
                background: Image.network(
                  'https://img.zcool.cn/community/01c6615d3ae047a8012187f447cfef.jpg@1280w_1l_2o_100sh.jpg',
                  fit: BoxFit.cover,
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.all(8.0),
              sliver: new SliverGrid( //Grid
                gridDelegate: new SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, //Grid按两列显示
                  mainAxisSpacing: 10.0,
                  crossAxisSpacing: 10.0,
                  childAspectRatio: 4.0,
                ),
                delegate: new SliverChildBuilderDelegate(
                      (BuildContext context, int index) {
                    //创建子widget      
                    return new Container(
                      alignment: Alignment.center,
                      color: Colors.cyan[100 * (index % 9)],
                      child: new Text('grid item $index'),
                    );
                  },
                  childCount: 10,
                ),
              ),
            ),
            SliverPersistentHeader(
              delegate: SliverTabBarDelegate(
                TabBar(
                  tabs: <Widget>[
                    Tab(text: 'Home'),
                    Tab(text: 'Profile'),
                  ],
                  indicatorColor: Colors.red,
                  unselectedLabelColor: Colors.black,
                  labelColor: Colors.red,
                  controller: tabController,
                ),
                color: Colors.white,
              ),
              pinned: true,
            ),
          ];
        },
        body: TabBarView(
          controller: tabController,
          children:[
            LongList<FeedItem>(
              id: id,
              mode: LongListMode.grid,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 10.0,
                mainAxisSpacing: 10.0,
              ),
              needRefresh: false,
              itemWidget: itemWidget,
            ),
            LongList<FeedItem>(
              id: 'test',
              mode: LongListMode.grid,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 10.0,
                mainAxisSpacing: 10.0,
              ),
              needRefresh: false,
              itemWidget: itemWidget,
            )
          ]
        ),
      ),
    );
  }
  Widget getChildWidget() {
    return Container(
      
    );
  }
  Widget itemWidget(BuildContext context, LongListProvider<FeedItem> provider, String id, int index, FeedItem data) {
    print('rebuild${index}');
    return Container(
      height: 400,
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

class SliverTabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar widget;
  final Color color;

  const SliverTabBarDelegate(this.widget, {this.color})
      : assert(widget != null);

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return new Container(
      child: widget,
      color: color,
    );
  }

  @override
  bool shouldRebuild(SliverTabBarDelegate oldDelegate) {
    return false;
  }

  @override
  double get maxExtent => widget.preferredSize.height;

  @override
  double get minExtent => widget.preferredSize.height;
}