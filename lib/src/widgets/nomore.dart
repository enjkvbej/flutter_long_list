import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class LongListNoMore extends StatelessWidget {
  final bool init;
  const LongListNoMore({this.init = false, Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      padding: EdgeInsets.only(top: 80, bottom: 80),
      child: Text(
        init ? '暂无相关内容' : '已经到底了',
        style: TextStyle(
          color: Colors.white.withOpacity(0.5),
          fontWeight: FontWeight.bold,
          fontSize: 13
        )
      )
    );
  }
}