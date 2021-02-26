# flutter_long_list

A Flutter LongList with Provider which supports ListView, GridView and Slivers

## Features

1. Support refresh & loadmore & error

2. Use Provider4.x to manage list data, and use Selector can improve performanc

3. Support ListView, GridView and Slivers

4. Easy api, custom loading & nomore style

5. Support List item exposure listener

6. Support ScrollToIndex

## Get started

Add it to your pubspec.yaml file:

```dart
  dependencies:
     flutter_long_list: 0.1.2
```

Install packages from the command line

```dart
  flutter packages get
```

If you like this package, consider supporting it by giving it a star on [Github](https://github.com/enjkvbej/flutter_long_list) and a like on [pub.dev](https://pub.dev/packages/flutter_long_list) ❤️

## Basic Usage

**Create a GridView By flutter_long_list**

### Step1 - Use ChangeNotifierProvider

```dart
 ChangeNotifierProvider<LongListProvider<T>>(
   create: (_) => LongListProvider<T>(),
   child: GridViewDemo(),
 );
```

### Step2 - Init LongListProvider

·param `id`: list custom id is required.

·param `pageSize`: list load more need pagesize to request.

·param `request`: list load more function, offset = page * pageSize(page initialValue = 0).

```dart
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

### Step3 - Use LongList

·param `id`: list custom id you have inited.

·param `gridDelegate`: gridView property.

·param `mode`: enum LongListMode {list, grid, sliver_list, sliver_grid}

·param `itemWidget`: `(BuildContext context, LongListProvider<T> provider, String id, int index, T data) { return your custom widget }`

```dart
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

## Feature Use

### 1. You can use it to make your list data shared. Need to be determined the list has inited before use these functions. Please see ListView example

```dart
prvider.list[id].addItem(id, index, data); // add item
prvider.list[id].addItems(id, data); // add list
prvider.list[id].changeItem(id, index, data); // delete item
prvider.list[id].removeItem(id, index); // remove item
```

* your data must have clone method, because provider `Selector` need.

### 2. If you want use exposure listener, only add exposureCallback

```dart
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

if use sliver mode, please must add 'sliverHeadHeight' param. It equals your sliverHead's expandedHeight.

### 3. Use ScrollToIndex

```dart
ScrollToIndexController scrollController = ScrollToIndexController();
scrollController.scrollToIndex(LongListProvider provider, String id, int index);
```
