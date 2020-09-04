import 'package:flutter/material.dart' show ChangeNotifier;


class LongListStore with ChangeNotifier {
  Map<String, List> _hashMapList = {};
  Map<String, List> get list => _hashMapList;

  /// 如何保证唯一
  saveListById(String id, List data) {
    _hashMapList[id] = data;
    print('_hashMapList${_hashMapList['list_view'].length}');
  }
}