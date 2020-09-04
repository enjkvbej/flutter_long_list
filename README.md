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
2. init GridView
