import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' show ChangeNotifier;
import 'package:flutter_long_list/src/store/long_list_store.dart';

/* 
 * 通用列表数据
 * 1._hashMapList添加list id唯一标识
 * 2.数据model必须添加clone方法 参照FeedItem
 * 3.使用LongList组件 进行init 注意ChangeNotifierProvider要先包到组件外层
 */
class LongListProvider<T extends Clone<T>> with ChangeNotifier {
  final LongListStore store;
  LongListProvider({this.store});

  List<T> _list = List<T>();
  LongListConfig _listConfig;
  bool _isLoading = false;
  bool _hasMore = true;
  bool _hasError = false;

  List<T> get list => _list;
  LongListConfig get listConfig => _listConfig;
  bool get isLoading => _isLoading;
  bool get hasMore => _hasMore;
  bool get hasError => _hasError;
  /// 初始化
  /// id: 唯一标识  全局数据时必须需要
  /// request function (offset, num) => list or error
  /// callback: 数据自定义事件
  init(
      {String id,
      @required int pageSize,
      @required Function request,
      Function callback}) async {
    _listConfig = LongListConfig(
        id: id, pageSize: pageSize, request: request, callback: callback);
    await _getList(init: true);
  }
  /// 获取数据的方法
  _getList({init = false}) async {
    // 使用providder不要在initState执行notifyListeners()
    if (!init) {
      _isLoading = true;
      notifyListeners();
    }
    final result = await _listConfig.request(_listConfig.offset);
    if (result['list'] != null &&
        result['total'] != null &&
        result['error'] == null) {
      _listConfig.total = result['total'];
      if (result['total'] == result['list'].length + _list.length) {
        _hasMore = false;
      }
      _isLoading = false;
      _addItems(result['list']);
    } else {
      _hasError = true;
      _isLoading = false;
      notifyListeners();
    }
  }
  _addItems(List<T> data) {
    _list.addAll(data);
    store?.saveListById(_listConfig.id, _list);
    if (_listConfig.callback != null) {
      _listConfig.callback(_list);
    }
    notifyListeners();
  }
  /// 刷新
  refresh() async {
    _listConfig.offset = 0;
    _hasMore = true;
    _hasError = false;
    _list.clear();
    await _getList();
  }
  /// 加载更多
  loadMore() async {
    _listConfig.offset += _listConfig.pageSize;
    await _getList();
  }
  /// 添加
  addItem(int index, T data, {String id}) {
    if (id != null) {
      store?.addListById(id, index, data);
    } else {
      _list[index] = data;
      notifyListeners();
    }
  }
  /// 修改
  changeItem(int index, T data, {String id}) {
    if (id != null) {
      store?.changeListById(id, index, data);
    } else {
      _list[index] = data;
      notifyListeners();
    }
  }
  /// 删除
  deleteItem(int index, {String id}) {
    if (id != null) {
      store?.deleteListById(id, index);
    } else {
      _list.removeAt(index);
      notifyListeners();
    }
  }
}

abstract class Clone<T> {
  T clone();
}

class LongListConfig {
  String id;
  int offset;
  int total;
  int pageSize;
  Function request;
  Function callback;

  LongListConfig({
    this.id,
    this.offset = 0,
    this.total = 0,
    this.pageSize,
    this.request,
    this.callback,
  });
}
