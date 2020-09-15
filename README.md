# flutter_long_list
A Flutter LongList with Provider which supports ListView, GridView and Slivers

# Features
1. Support refresh & loadmore & error
1. Use Provider4.x to manage list data , and use Selector can improve performance<br>
2. Support ListView, GridView and Slivers <br>
3. Easy api, custom loading & nomore style <br>
4. Support List item exposure listener <br>

# Get started
Add it to your pubspec.yaml file:
```
  dependencies:
     flutter_long_list: ^0.0.6
```
Install packages from the command line
```
  flutter packages get
```
If you like this package, consider supporting it by giving it a star on [Github](https://github.com/enjkvbej/flutter_long_list) and a like on [pub.dev](https://pub.dev/packages/flutter_long_list) ❤️

# Usage
How to create a GridView By flutter_long_list:
1. use ChangeNotifierProvider
```
 ChangeNotifierProvider<LongListProvider<T>>(
   create: (_) => LongListProvider<T>(),
   child: GridViewDemo(),
 );
```
2. init GridView<br>
·param id: list custom id if you use globalStore is required.<br>
·param pageSize: list load more need pagesize to request.<br>
·param request: list load more function, offset = page * pageSize(page initialValue = 0).<br>
```
@override
initState() {
  longListProvider.init(
    id: id,
    pageSize: 5,
    request: (int offset) async => await _getList(offset),
  );
  // your code...
}
// 'list' & 'total' & 'error' can not be modified. These field will use to loadmore.
_getList(offset) {
  final result = await api(0, 5); // your request api
  if (result['list'] != null) {
    return {
      'list': result['list'], 
      'total': result['total']
    };
  } else {
    return {
      'error': 'error'
    };
  }
}
```
3. render GridView<br>
·param id: list custom id you have inited.<br>
·param gridDelegate: gridView property.<br>
·param mode: enum LongListMode {list, grid, sliver_list, sliver_grid}<br>
·param itemWidget: (BuildContext context, LongListProvider<T> provider, String id, int index, T data) { return your custom widget}<br>

```
LongList<T>(
  id: id,
  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
    crossAxisCount: 2,
    crossAxisSpacing: 10.0,
    mainAxisSpacing: 10.0,
  ),
  padding: EdgeInsets.only(left: 10, right: 10),
  mode: LongListMode.grid,
  itemWidget: itemWidget,
)
```
Then you have finished to create a LongList GridView Widget easily!

# Notice
1.LongListStore is a global provider Store.You can use it to make your list data share. Please see example if you want to it.<br>
2.If you want use exposure listener, only add exposureCallback as:
```
LongList<T>(
  id: id,
  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
    crossAxisCount: 2,
    crossAxisSpacing: 10.0,
    mainAxisSpacing: 10.0,
  ),
  padding: EdgeInsets.only(left: 10, right: 10),
  mode: LongListMode.grid,
  itemWidget: itemWidget,
  exposureCallback: (LongListProvider<T> provider, List<ToExposureItem> exposureList) {
    exposureList.forEach((item) {
      print('上报数据：${provider.list[item.index]} ${item.index} ${item.time}');
    });
  },
)
```
if use sliver mode, please add 'sliverHeadHeight' param. It equals your sliverHead's expandedHeight.