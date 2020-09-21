import 'package:example/model/feed_item.dart';
import 'package:example/widgets/sliver_custom.dart';
import 'package:flutter/material.dart';
import 'package:flutter_long_list/flutter_long_list.dart';
import 'package:provider/provider.dart';

class SliverCustomViewPage extends StatelessWidget {
  const SliverCustomViewPage({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialButton(
      onPressed: () {
        Navigator.push(
          context,
          PageRouteBuilder(pageBuilder: (_,
              Animation animation, Animation secondaryAnimation) {
            return ChangeNotifierProvider<LongListProvider<FeedItem>>(
              create: (_) => LongListProvider<FeedItem>(),
              child: SliverCustomViewDemo(),
            );
          }),
        );
      },
      color: Colors.grey,
      height: 40,
      child: Text(
        'SliverCustomView'
      ),
    );
  }
}
