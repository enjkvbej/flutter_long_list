import 'dart:math';

import 'package:flutter/material.dart';

import '../model/feed_item.dart';


Future api(int offset, int number) {
  int total = 100;
  List<FeedItem> list = List();
  Map<String, dynamic> result;
  FeedItem _getItem () {
    return FeedItem(
      Color.fromARGB(255, Random.secure().nextInt(255),
        Random.secure().nextInt(255), Random.secure().nextInt(255)),
      false
    );
  }
  for (var i = 0; i < number; ++i) {
    list.add(_getItem());
  }
  return Future<void>.delayed(const Duration(seconds: 1), () {
    result = {
      'total': total,
      'list': list,
    };
    return result;
  });
}