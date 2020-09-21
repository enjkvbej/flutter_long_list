import 'package:example/model/feed_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_long_list/flutter_long_list.dart';

class ListLike extends StatefulWidget {
  ListLike({Key key}) : super(key: key);

  @override
  _ListLikeState createState() => _ListLikeState();
}

class _ListLikeState extends State<ListLike> with AutomaticKeepAliveClientMixin{
  String id = 'list_like';
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LongList<FeedItem>(
        id: id,
        itemWidget: itemWidget,
      )
    );
  }

  Widget itemWidget(BuildContext context, LongListProvider<FeedItem> provider, String id, int index, FeedItem data) {
    return  Container(
      height: 200,
      width: double.infinity,
      alignment: Alignment.center,
      color: data.color,
      child: Text(
        '${data.text}'
      )
    ); 
  }
}