import 'package:extended_list/extended_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_long_list/src/store/long_list_provider.dart';
import './long_list.dart';

class LongListBuilder<T extends Clone<T>> extends StatelessWidget {
  final String id;
  final LongListMode mode;
  final int itemCount;
  final double cacheExtent;
  final LongListProvider<T> provider;
  final EdgeInsetsGeometry padding;
  final Axis scrollDirection;
  final SliverGridDelegate gridDelegate;
  final ScrollToIndexController controller;
  final Function(BuildContext context, int index) child;
  final Widget sliverAppBar;
  final Widget sliverHead;
  final List<Widget> sliverChildren;
  final bool shrinkWrap;
  final ScrollPhysics physics;
  const LongListBuilder({
    this.id,
    this.mode,
    this.cacheExtent,
    @required this.itemCount,
    @required this.provider,
    this.padding,
    this.shrinkWrap,
    this.physics,
    this.scrollDirection,
    this.controller,
    this.gridDelegate,
    this.child,
    this.sliverAppBar,
    this.sliverHead,
    this.sliverChildren,
    Key key
  }) : super(key: key);
  
  getExtendedListDelegate() {
    return ExtendedListDelegate(
      lastChildLayoutTypeBuilder: (int index) => ((!provider.listConfig[id].hasMore || provider.listConfig[id].isLoading || provider.listConfig[id].hasError)
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
        shrinkWrap: shrinkWrap,
        cacheExtent: cacheExtent,
        physics: physics,
        controller: controller,
        itemCount: itemCount,
        itemBuilder: child,
      );
    } else if (mode == LongListMode.list) {
      return ExtendedListView.builder(
        padding: padding,
        extendedListDelegate: getExtendedListDelegate(),
        scrollDirection: scrollDirection,
        shrinkWrap: shrinkWrap,
        cacheExtent: cacheExtent,
        physics: physics,
        controller: controller,
        itemCount: itemCount,
        itemBuilder: child,
      );
    } else if (mode == LongListMode.sliver_grid) {
      List<Widget> slivers = [
        ExtendedSliverGrid(
          delegate: SliverChildBuilderDelegate(
            child,
            childCount: itemCount,
          ),
          gridDelegate: gridDelegate,
          extendedListDelegate: getExtendedListDelegate(),
        ),
      ];
      if (sliverAppBar != null) {
        slivers.insert(0, sliverAppBar);
      }
      if (sliverHead != null) {
        slivers.insert(slivers.length == 2 ? 1 : 0, sliverHead);
      }
      if (sliverChildren != null) {
        slivers.insertAll(slivers.length - 1, sliverChildren);
      }
      return CustomScrollView(
        scrollDirection: scrollDirection,
        controller: controller,
        shrinkWrap: shrinkWrap,
        cacheExtent: cacheExtent,
        physics: physics,
        slivers: slivers
      );
    } else if (mode == LongListMode.sliver_list) {
      List<Widget> slivers = [
        ExtendedSliverList(
          extendedListDelegate: getExtendedListDelegate(),
          delegate: SliverChildBuilderDelegate(
            child,
            childCount: itemCount,
          ),
        ),
      ];
      if (sliverAppBar != null) {
        slivers.insert(0, sliverAppBar);
      }
      if (sliverHead != null) {
        slivers.insert(slivers.length == 2 ? 1 : 0, sliverHead);
      }
      if (sliverChildren != null) {
        slivers.insertAll(slivers.length - 1, sliverChildren);
      }
      return CustomScrollView(
        scrollDirection: scrollDirection,
        controller: controller,
        shrinkWrap: shrinkWrap,
        cacheExtent: cacheExtent,
        physics: physics,
        slivers: slivers
      );
    } else {
      return Text('LongListMode传值错误');
    }
  }
}
