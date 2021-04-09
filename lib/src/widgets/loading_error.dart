import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_long_list/src/store/long_list_provider.dart';
import 'package:provider/provider.dart';


class LongListLoadingError<T extends Clone<T>> extends StatelessWidget {
  final String id;
  final Widget child;
  const LongListLoadingError({this.id, this.child, Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      padding: EdgeInsets.only(top: 40, bottom: 40),
      child: child ?? loading(context)
    );
  }
  
  Widget loading(BuildContext context) {
    return TextButton(
      onPressed: () {
        context.read<LongListProvider<T>>().reLoadMore(id);
      },
      child: Text('加载错误，请刷新'),
    );
  }
}