import 'package:flutter/material.dart';
import 'package:flutter_long_list/flutter_long_list.dart';

class FeedItem with Clone<FeedItem>{
  Color color;
  bool like;
  FeedItem(this.color, this.like);

  @override
  FeedItem clone() {
    return FeedItem(
      color,
      like,
    );
  }
}