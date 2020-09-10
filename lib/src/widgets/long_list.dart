import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_long_list/src/utils/exposure.dart';
import 'package:flutter_long_list/src/widgets/exposure_listener.dart';
import 'package:provider/provider.dart';
import 'package:tuple/tuple.dart';
import '../store/long_list_provider.dart';
import './loading.dart';
import './long_list_builder.dart';
import './nomore.dart';
import './overflow_widget.dart';
import './error.dart';

enum LongListMode {grid, list, sliver_grid, sliver_list, sliver_custom}
class LongList<T extends Clone<T>> extends StatelessWidget {
  final String id;
  final LongListMode mode;
  final EdgeInsets padding;
  final ScrollController controller;
  final SliverGridDelegate gridDelegate;
  final Axis scrollDirection;
  final Function(BuildContext context, LongListProvider<T> provider, String id,
      int index, T data) itemWidget;
  final Widget sliverHead;
  final double sliverHeadHeight;
  final Widget loading;
  final Exposure exposure = Exposure();

  LongList({
    Key key,
    @required this.id,
    @required this.itemWidget,
    this.mode = LongListMode.list,
    this.padding = const EdgeInsets.all(0.0),
    this.controller,
    this.gridDelegate,
    this.scrollDirection = Axis.vertical,
    this.sliverHead,
    this.sliverHeadHeight,
    this.loading,
  }) : assert(id != null), assert(itemWidget != null),
    super(key: key);

  _loadmore(context) {
    LongListProvider<T> provider = Provider.of<LongListProvider<T>>(context, listen: false);
    if (provider.hasMore && !provider.hasError && !provider.isLoading) {
      provider.loadMore(id);
    }
  }

  Future _onRefresh(LongListProvider<T> provider) async{
    await provider.refresh(id);
  }

  @override
  Widget build(BuildContext context) {
    return ExposureListener(
      scrollDirection: Axis.vertical,
      exposure: exposure,
      padding: padding,
      sliverHeadHeight: sliverHeadHeight,
      loadmore: () => _loadmore(context),
      callback: (list) {
        list.forEach((item) {
          print('上报数据：${item.index}');
        });
      },
      child: GlowNotificationWidget(
        showGlowLeading: false,
        showGlowTrailing: false,
        child: Selector<LongListProvider<T>, Tuple4<int, bool, bool, bool>>(
          selector: (_, provider) => Tuple4(
            provider.list.length,
            provider.isLoading,
            provider.hasMore,
            provider.hasError,
          ),
          shouldRebuild: (pre, next) => pre != next,
          builder: (_, data, __) {
            LongListProvider<T> _provider = context.read<LongListProvider<T>>();
            if (data.item1 > 0) {
              return RefreshIndicator(
                onRefresh: () => _onRefresh(_provider),
                child: LongListBuilder(
                  mode: mode,
                  provider: _provider,
                  controller: controller,
                  scrollDirection: scrollDirection,
                  gridDelegate: gridDelegate,
                  padding: padding,
                  itemCount: (data.item2 || !data.item3) ? data.item1 + 1 : data.item1,
                  sliverHead: sliverHead,
                  child: (context, index) {
                    if (!data.item3 && _provider.list.length == index) {
                      return LongListNoMore();
                    } else if (data.item2 && data.item1 == index) {
                      return LongListLoading(
                        position: LoadingPosition.bottom,
                        child: loading,
                      );
                    } else {
                      return Selector<LongListProvider<T>, T>(
                        shouldRebuild: (pre, next) => pre != next,
                        selector: (_, provider) => provider.list[index],
                        builder: (_, data, __) {
                          return itemWidget(
                            context,
                            _provider,
                            id,
                            index,
                            data.clone(),
                          );
                        }
                      );
                    }
                  },
                )
              );
            } else {
              if (!data.item3) {
                return LongListNoMore(init: true);
              } else if (data.item4) {
                return LongListError<T>(id: id);
              } else {
                return LongListLoading(
                  position: LoadingPosition.center,
                  child: loading,
                );
              }
            }
          }
        ),
      ),
    );
  }
}
