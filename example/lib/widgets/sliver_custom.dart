import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_long_list/flutter_long_list.dart';
import '../api/http.dart';
import '../model/feed_item.dart';

class SliverCustomViewDemo extends StatefulWidget {
  SliverCustomViewDemo({Key key}) : super(key: key);

  @override
  _SliverCustomViewDemoState createState() => _SliverCustomViewDemoState();
}

class _SliverCustomViewDemoState extends State<SliverCustomViewDemo> {
  String id = 'sliver_custom';
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
        mode: LongListMode.sliver_list,
        sliverHead: SliverPersistentHeader(
          pinned: true,
          delegate: SliverCustomHeaderDelegate(
            title: '哪吒之魔童降世',
            collapsedHeight: 40,
            expandedHeight: 300,
            paddingTop: MediaQuery.of(context).padding.top,
            coverImgUrl: 'https://img.zcool.cn/community/01c6615d3ae047a8012187f447cfef.jpg@1280w_1l_2o_100sh.jpg'
          ),
        ),
        sliverHeadHeight: 300,
        sliverChildren: [
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
        ],
        itemWidget: itemWidget,
        exposureCallback: (LongListProvider<FeedItem> provider, List<ToExposureItem> exposureList) {
          exposureList.forEach((item) {
            print('上报数据：${provider.list[id][item.index].color} ${item.index} ${item.time}');
          });
        },
      )
    );
  }
  Widget getChildWidget() {
    return Container(
      
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

class SliverCustomHeaderDelegate extends SliverPersistentHeaderDelegate {
  final double collapsedHeight;
  final double expandedHeight;
  final double paddingTop;
  final String coverImgUrl;
  final String title;
  String statusBarMode = 'dark';

  SliverCustomHeaderDelegate({
    this.collapsedHeight,
    this.expandedHeight,
    this.paddingTop,
    this.coverImgUrl,
    this.title,
  });

  @override
  double get minExtent => this.collapsedHeight + this.paddingTop;

  @override
  double get maxExtent => this.expandedHeight;

  @override
  bool shouldRebuild(SliverPersistentHeaderDelegate oldDelegate) {
    return true;
  }

  void updateStatusBarBrightness(shrinkOffset) {
    if(shrinkOffset > 50 && this.statusBarMode == 'dark') {
      this.statusBarMode = 'light';
      SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
        statusBarBrightness: Brightness.light,
        statusBarIconBrightness: Brightness.light,
      ));
    } else if(shrinkOffset <= 50 && this.statusBarMode == 'light') {
      this.statusBarMode = 'dark';
      SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
        statusBarBrightness: Brightness.dark,
        statusBarIconBrightness: Brightness.dark,
      ));
    }
  }

  Color makeStickyHeaderBgColor(shrinkOffset) {
    final int alpha = (shrinkOffset / (this.maxExtent - this.minExtent) * 255).clamp(0, 255).toInt();
    return Color.fromARGB(alpha, 255, 255, 255);
  }

  Color makeStickyHeaderTextColor(shrinkOffset, isIcon) {
    if(shrinkOffset <= 50) {
      return isIcon ? Colors.white : Colors.transparent;
    } else {
      final int alpha = (shrinkOffset / (this.maxExtent - this.minExtent) * 255).clamp(0, 255).toInt();
      return Color.fromARGB(alpha, 0, 0, 0);
    }
  }

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    this.updateStatusBarBrightness(shrinkOffset);
    return Container(
      height: this.maxExtent,
      width: MediaQuery.of(context).size.width,
      child: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          Container(child: Image.network(this.coverImgUrl, fit: BoxFit.cover)),
          Positioned(
            left: 0,
            top: this.maxExtent / 2,
            right: 0,
            bottom: 0,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0x00000000),
                    Color(0x90000000),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            top: 0,
            child: Container(
              color: this.makeStickyHeaderBgColor(shrinkOffset),
              child: SafeArea(
                bottom: false,
                child: Container(
                  height: this.collapsedHeight,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      IconButton(
                        icon: Icon(
                          Icons.arrow_back_ios,
                          color: this.makeStickyHeaderTextColor(shrinkOffset, true),
                        ),
                        onPressed: () => Navigator.pop(context),
                      ),
                      Text(
                        this.title,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                          color: this.makeStickyHeaderTextColor(shrinkOffset, false),
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.share,
                          color: this.makeStickyHeaderTextColor(shrinkOffset, true),
                        ),
                        onPressed: () {},
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}