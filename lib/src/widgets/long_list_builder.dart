import 'package:extended_list/extended_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import './long_list.dart';

class LongListBuilder extends StatelessWidget {
  final LongListMode mode;
  final int itemCount;
  final EdgeInsetsGeometry padding;
  final Axis scrollDirection;
  final ScrollController controller;
  final Function(BuildContext context, int index) child;
  final Widget sliverHead;
  const LongListBuilder({
    this.mode,
    @required this.itemCount,
    this.padding,
    this.scrollDirection,
    this.controller,
    this.child,
    this.sliverHead,
    Key key
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (mode == LongListMode.grid) {
      return ExtendedGridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 10.0,
          mainAxisSpacing: 10.0,
        ),
        extendedListDelegate: ExtendedListDelegate(
          lastChildLayoutTypeBuilder: (int index) => index == itemCount - 1
              ? LastChildLayoutType.fullCrossAxisExtent
              : LastChildLayoutType.none,
        ),
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
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10.0,
            ),
            extendedListDelegate: ExtendedListDelegate(
              lastChildLayoutTypeBuilder: (int index) => index == itemCount - 1
                  ? LastChildLayoutType.fullCrossAxisExtent
                  : LastChildLayoutType.none,
            ),
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