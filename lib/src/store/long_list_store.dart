import 'package:flutter/material.dart' show ChangeNotifier;


class LongListStore with ChangeNotifier {
  Map<String, List> _hashMapList = {};
  Map<String, List> get list => _hashMapList;

  saveListById(String id, List data) {
    _hashMapList[id] = data;
  }
}