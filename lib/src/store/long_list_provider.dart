import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' show ChangeNotifier, GlobalKey;

class LongListData {
  /// list数据
  final List<dynamic> list;
  /// list总数
  final int total;
  /// list是否更多标志位
  final bool hasMore;
  /// list加载错误标志位
  final dynamic error;
  LongListData({this.list, this.total, this.hasMore, this.error});
}
/* 
 * 通用列表数据
 * 1._hashMapList添加list id唯一标识
 * 2.数据model必须添加clone方法 参照FeedItem
 * 3.使用LongList组件 进行init 注意ChangeNotifierProvider要先包到组件外层
 */
class LongListProvider<T extends Clone<T>> with ChangeNotifier {
  Map<String, List<T>> _hashMapList = {};
  Map<String, LongListConfig> _listConfig = {};
  Map<String, List<T>> get list => _hashMapList;
  Map<String, LongListConfig> get listConfig => _listConfig;
  /// 销毁时的标志位，用来禁止后续对provider操作
  bool _disposed = false;
  /// 初始化
  /// id: 唯一标识  全局数据时必须需要
  /// request function (offset, num) => list or error
  /// callback: 数据自定义事件
  init(
      {@required String id,
      @required int pageSize,
      @required Future<LongListData> Function(int) request,
      Function callback}) async {
        if (_hashMapList[id] == null) {
          _hashMapList[id] = [];
        }
    _listConfig[id] = LongListConfig(
        id: id, pageSize: pageSize, request: request, callback: callback);
    await _getList(id, init: true);
  }
  // 获取数据的方法
  _getList(String id, {init = false}) async {
    // 使用providder不要在initState执行notifyListeners()
    if (!init) {
      _listConfig[id].isLoading = true;
      notifyListeners();
    }
    LongListData result = await _listConfig[id].request(_listConfig[id].offset);
    if (result.list != null && result.error == null) {
      if (result.hasMore != null) {
        _listConfig[id].hasMore = result.hasMore;
      } else {
        if (result.total != null) {
          _listConfig[id].total = result.total;
          if (result.total == result.list.length + _hashMapList[id].length) {
            _listConfig[id].hasMore = false;
          }
        }
      }
      _listConfig[id].isLoading = false;
      addItems(id, result.list);
    } else {
      _listConfig[id].hasError = true;
      _listConfig[id].isLoading = false;
      notifyListeners();
    }
  }
  // 检验并生成id
  _checkId(String id) {
    if (_hashMapList[id] == null) {
      return false;
    }
    return true;
  }

  saveScrollKey(String id, GlobalKey key) {
    _listConfig[id].key = key;
  }

  /// 添加数组
  addItems(String id, List<T> data) {
    if(_disposed) {
      return;
    }
    _hashMapList[id].addAll(data);
    if (_listConfig[id].callback != null) {
      _listConfig[id].callback(_hashMapList[id]);
    }
    notifyListeners();
  }

  /// 刷新
  refresh(String id) async {
    if (_checkId(id)) {
      _listConfig[id].offset = 0;
      _listConfig[id].hasMore = true;
      _listConfig[id].hasError = false;
      _hashMapList[id].clear();
      await _getList(id);
    } else {
      print('list id${id}没有初始化');
    }
  }

  /// 加载重试
  reLoadMore(String id) async {
    if (_checkId(id)) {
      await _getList(id);
    } else {
      print('list id${id}没有初始化');
    }
  }

  /// 加载更多
  loadMore(String id) async {
    if (_checkId(id)) {
      _listConfig[id].offset += _listConfig[id].pageSize;
      await _getList(id);
    } else {
      print('list id${id}没有初始化');
    }
  }

  /// 添加
  addItem(String id, int index, T data) {
    if (_checkId(id))  {
      _hashMapList[id].insert(index, data);
      notifyListeners();
    } else {
      print('list id${id}没有初始化');
    }
  }

  /// 修改
  changeItem(String id, int index, T data) {
    if (_checkId(id))  {
      _hashMapList[id][index] = data;
      notifyListeners();
    } else {
      print('list id${id}没有初始化');
    }
  }

  /// 删除
  removeItem(String id, int index) {
    if (_checkId(id))  {
      _hashMapList[id].removeAt(index);
      notifyListeners();
    } else {
      print('list id${id}没有初始化');
    }
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}

abstract class Clone<T> {
  final GlobalKey globalKey = GlobalKey();
  T clone();
}

class LongListConfig {
  GlobalKey key;
  String id;
  int offset;
  int total;
  int pageSize;
  Future<LongListData> Function(int) request;
  Function callback;
  bool isLoading;
  bool hasMore;
  bool hasError;

  LongListConfig({
    this.key,
    this.id,
    this.offset = 0,
    this.total = 0,
    this.pageSize,
    this.request,
    this.callback,
    this.isLoading = true, /// 初始化改为true
    this.hasMore = true,
    this.hasError = false,
  });
}
