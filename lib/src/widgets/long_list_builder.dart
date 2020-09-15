import 'package:extended_list/extended_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_long_list/src/store/long_list_provider.dart';
import './long_list.dart';

class LongListBuilder<T extends Clone<T>> extends StatelessWidget {
  final LongListMode mode;
  final int itemCount;
  final LongListProvider<T> provider;
  final EdgeInsetsGeometry padding;
  final Axis scrollDirection;
  final SliverGridDelegate gridDelegate;
  final ScrollController controller;
  final Function(BuildContext context, int index) child;
  final Widget sliverHead;
  final List<Widget> sliverChildren;
  const LongListBuilder({
    this.mode,
    @required this.itemCount,
    @required this.provider,
    this.padding,
    this.scrollDirection,
    this.controller,
    this.gridDelegate,
    this.child,
    this.sliverHead,
    this.sliverChildren,
    Key key
  }) : super(key: key);
  
  getExtendedListDelegate() {
    return ExtendedListDelegate(
      lastChildLayoutTypeBuilder: (int index) => ((!provider.hasMore || provider.isLoading || provider.hasError)
        && index == itemCount - 1)
        ? LastChildLayoutType.fullCrossAxisExtent
        : LastChildLayoutType.none
    );
  }
  @override
  Widget build(BuildContext context) {
    if (mode == LongListMode.grid) {
      return ExtendedGridView.builder(
        gridDelegate: gridDelegate,
        extendedListDelegate: getExtendedListDelegate(),
        padding: padding,
        scrollDirection: scrollDirection,
        shrinkWrap: true,
        controller: controller,
        itemCount: itemCount,
        itemBuilder: child,
      );
    } else if (mode == LongListMode.list) {
      return ExtendedListView.builder(
        padding: padding,
        extendedListDelegate: getExtendedListDelegate(),
        scrollDirection: scrollDirection,
        shrinkWrap: true,
        controller: controller,
        itemCount: itemCount,
        itemBuilder: child,
      );
    } else if (mode == LongListMode.sliver_grid) {
      return CustomScrollView(
        scrollDirection: scrollDirection,
        controller: controller,
        slivers: <Widget>[
          sliverHead,
          ExtendedSliverGrid(
            delegate: SliverChildBuilderDelegate(
              child,
              childCount: itemCount,
            ),
            gridDelegate: gridDelegate,
            extendedListDelegate: getExtendedListDelegate(),
          ),
        ],
      );
    } else if (mode == LongListMode.sliver_list) {
      return CustomScrollView(
        scrollDirection: scrollDirection,
        controller: controller,
        slivers: <Widget>[
          sliverHead,
          ExtendedSliverList(
            extendedListDelegate: getExtendedListDelegate(),
            delegate: SliverChildBuilderDelegate(
              child,
              childCount: itemCount,
            ),
          ),
        ],
      );
    } else if (mode == LongListMode.sliver_custom) {
      return CustomScrollView(
        scrollDirection: scrollDirection,
        controller: controller,
        slivers: <Widget>[
          sliverHead,
          ...sliverChildren,
          ExtendedSliverList(
            extendedListDelegate: getExtendedListDelegate(),
            delegate: SliverChildBuilderDelegate(
              child,
              childCount: itemCount,
            ),
          ),
        ],
      );
    } else {
      return Text('LongListMode传值错误');
    }
  }
}