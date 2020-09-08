# flutter_long_list
A Flutter LongList with Provider which supports ListView, GridView and Slivers

# Features
1. Use Provider4.x to manage list data , and use Selector can improve performance<br>
2. Supports ListView, GridView and Slivers <br>
3. Custom and easy api <br>

# Get started
Add it to your pubspec.yaml file:
```
  dependencies:
     flutter_long_list: ^0.0.1
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