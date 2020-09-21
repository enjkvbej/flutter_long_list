import 'package:flutter/material.dart';
import 'package:flutter_long_list/flutter_long_list.dart';

class FeedItem with Clone<FeedItem>{
  Color color;
  int text;
  bool like;
  FeedItem(this.color, this.text, this.like);

  @override
  FeedItem clone() {
    return FeedItem(
      color,
      text,
      like,
    );
  }
}