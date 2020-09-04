import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';


enum LoadingPosition {center, bottom}
class LongListLoading extends StatelessWidget {
  final LoadingPosition position;
  final Widget child;
  const LongListLoading({this.position, this.child, Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (position == LoadingPosition.center) {
      return Center(
        child: child ?? loading()
      );
    } else if (position == LoadingPosition.bottom) {
      return Container(
        alignment: Alignment.center,
        padding: EdgeInsets.only(top: 40, bottom: 40),
        child: child ?? loading()
      );
    } else {
      return Container(width: 0, height: 0);
    }
  }
  
  Widget loading() {
    return SizedBox(
      child: Text('londing。。。')
    );
  }
}