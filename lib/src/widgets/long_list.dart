

import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_long_list/src/widgets/multi_exposure_listener.dart';
import 'package:provider/provider.dart';
import 'package:tuple/tuple.dart';
import '../store/long_list_provider.dart';
import '../utils/exposure.dart';
import './loading.dart';
import './long_list_builder.dart';
import './nomore.dart';
import './overflow_widget.dart';
import './error.dart';
import './exposure_listener.dart';

enum LongListMode {grid, list, sliver_grid, sliver_list, sliver_custom}

class LongList<T extends Clone<T>> extends StatefulWidget {
  final String id;
  final bool shrinkWrap;
  final ScrollPhysics physics;
  final LongListMode mode;
  final EdgeInsets padding;
  final double cacheExtent;
  final ScrollToIndexController controller;
  final SliverGridDelegate gridDelegate;
  final Axis scrollDirection;
  final Function(BuildContext context, LongListProvider<T> provider, String id,
      int index, T data) itemWidget;
  final Function exposureCallback;
  final Widget loading;
  final Function(bool init) nomore;
  final Widget sliverHead;
  final double sliverHeadHeight;
  final List<Widget> sliverChildren;

  final Exposure exposure = Exposure();

  LongList({
    Key key,
    this.id,
    this.shrinkWrap = false,
    this.physics,
    this.cacheExtent,
    @required this.itemWidget,
    this.mode = LongListMode.list,
    this.padding = const EdgeInsets.all(0.0),
    this.loading,
    this.nomore,
    this.controller,
    this.gridDelegate,
    this.scrollDirection = Axis.vertical,
    this.exposureCallback,
    this.sliverHead,
    this.sliverChildren,
    this.sliverHeadHeight,
  }) : assert(itemWidget != null),
    super(key: key);

  @override
  _LongListWidgetState createState() => _LongListWidgetState<T>();
}

class _LongListWidgetState<T extends Clone<T>> extends State<LongList<T>> {
  final GlobalKey _scrollKey = GlobalKey();
  
  @override
  void initState() {
    super.initState();
    LongListProvider<T> provider = Provider.of<LongListProvider<T>>(context, listen: false);
    provider.saveScrollKey(widget.id, _scrollKey);
  }

  @override
  void dispose() {
    widget.controller?.dispose();
    super.dispose();
  }

  void _loadmore(BuildContext context) {
    LongListProvider<T> provider = Provider.of<LongListProvider<T>>(context, listen: false);
    if (provider.listConfig[widget.id].hasMore && !provider.listConfig[widget.id].hasError && !provider.listConfig[widget.id].isLoading) {
      provider.loadMore(widget.id);
    }
  }

  Future _onRefresh(LongListProvider<T> provider) async{
    await provider.refresh(widget.id);
  }
  
  void _exposureCallback(BuildContext context, List<ToExposureItem> exposureList) {
    LongListProvider<T> provider = Provider.of<LongListProvider<T>>(context, listen: false);
    if (exposureList.isNotEmpty && widget.exposureCallback != null) {
      return widget.exposureCallback(provider, exposureList);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.mode != LongListMode.sliver_custom) {
      return ExposureListener<T>(
        id: widget.id,
        scrollDirection: Axis.vertical,
        exposure: widget.exposure,
        padding: widget.padding,
        sliverHeadHeight: widget.sliverHeadHeight,
        loadmore: () => _loadmore(context),
        callback: (exposureList) => _exposureCallback(context, exposureList),
        child: longList(context)
      );
    } else {
      return MultiExposureListener(
        scrollDirection: Axis.vertical,
        exposure: widget.exposure,
        padding: widget.padding,
        sliverHeadHeight: widget.sliverHeadHeight,
        loadmore: () => _loadmore(context),
        callback: (exposureList) => _exposureCallback(context, exposureList),
        child: longList(context)
      );
    }
  }

  Widget longList(BuildContext context) {
    return GlowNotificationWidget(
      showGlowLeading: false,
      showGlowTrailing: false,
      child: Selector<LongListProvider<T>, Tuple4<int, bool, bool, bool>>(
        selector: (_, provider) => Tuple4(
          provider.list[widget.id].length,
          provider.listConfig[widget.id].isLoading,
          provider.listConfig[widget.id].hasMore,
          provider.listConfig[widget.id].hasError,
        ),
        shouldRebuild: (pre, next) => pre != next,
        builder: (_, data, __) {
          LongListProvider<T> _provider = context.read<LongListProvider<T>>();
          if (data.item1 > 0) {
            return RefreshIndicator(
              onRefresh: () => _onRefresh(_provider),
              child: LongListBuilder(
                key: _scrollKey,
                id: widget.id,
                mode: widget.mode,
                shrinkWrap: widget.shrinkWrap,
                physics: widget.physics,
                cacheExtent: widget.cacheExtent,
                provider: _provider,
                controller: widget.controller,
                scrollDirection: widget.scrollDirection,
                gridDelegate: widget.gridDelegate,
                padding: widget.padding,
                itemCount: (data.item2 || !data.item3) ? data.item1 + 1 : data.item1,
                sliverHead: widget.sliverHead,
                sliverChildren: widget.sliverChildren,
                child: (context, index) {
                  if (!data.item3 && _provider.list[widget.id].length == index) {
                    return LongListNoMore(
                      child: widget.nomore
                    );
                  } else if (data.item2 && data.item1 == index) {
                    return LongListLoading(
                      position: LoadingPosition.bottom,
                      child: widget.loading,
                    );
                  } else {
                    return Selector<LongListProvider<T>, T>(
                      shouldRebuild: (pre, next) => pre != next,
                      selector: (_, provider) => provider.list[widget.id][index],
                      builder: (_, data, __) {
                        return Container(
                          key: data.globalKey,
                          child: widget.itemWidget(
                            context,
                            _provider,
                            widget.id,
                            index,
                            data.clone(),
                          )
                        );
                      }
                    );
                  }
                },
              )
            );
          } else {
            if (!data.item3) {
              return LongListNoMore(
                init: true,
                child: widget.nomore,
              );
            } else if (data.item4) {
              return LongListError<T>(id: widget.id);
            } else {
              return LongListLoading(
                position: LoadingPosition.center,
                child: widget.loading,
              );
            }
          }
        }
      ),
    );
  }
}

class ScrollToIndexController extends ScrollController {
  ScrollToIndexController() : super();
  /// 滑动到指定位置
  void scrollToIndex(LongListProvider provider, String id, int index, {bool animate: true, Duration duration, Curves curve, double offsetTop: 0.0}) {
    if (index > provider.list[id].length) {
      return;
    }
    dynamic item = provider.list[id][index];
    if (item.globalKey.currentContext != null) {
      RenderBox renderBox = item.globalKey.currentContext.findRenderObject();
      double dy = renderBox.localToGlobal(Offset.zero, ancestor: provider.listConfig[id].key.currentContext.findRenderObject()).dy;
      var offset = dy + super.offset;
      if (animate) {
        super.animateTo(offset - offsetTop, duration: duration ?? Duration(milliseconds: 100), curve: curve ?? Curves.linear);
      } else {
        super.jumpTo(offset - offsetTop);
      }
    } else {
      print("Please bind the key to the widget in the outermost layer of the Item layout");
    }
  }
}

