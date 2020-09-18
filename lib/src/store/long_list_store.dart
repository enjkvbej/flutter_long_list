import 'package:flutter/material.dart' show ChangeNotifier;


class LongListStore with ChangeNotifier {
  Map<String, List> _hashMapList = {};
  Map<String, List> get list => _hashMapList;
  
  /// save global
  saveListById(String id, List data) {
    _hashMapList[id] = data;
    notifyListeners();
  }

  /// add by id
  addListById(String id, int index, data) {
    _hashMapList[id].insert(index, data);
    notifyListeners();
  }

  /// change by id
  changeListById(String id, int index, data) {
    _hashMapList[id][index] = data;
    notifyListeners();
  }
  
  /// delete by id
  deleteListById(String id, int index) {
    _hashMapList[id].removeAt(index);
    notifyListeners();
  }
}