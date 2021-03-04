import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_long_list/src/store/long_list_provider.dart';
import 'package:provider/provider.dart';
import '../utils/exposure.dart';

typedef ExposureCallback = void Function(List<ToExposureItem> list);

class ExposureListener<T extends Clone<T>> extends StatelessWidget {
  final String id;
  final Function loadmore;
  final Widget child;
  final ExposureCallback callback;
  final Axis scrollDirection;
  final double sliverHeadHeight;
  final EdgeInsets padding;
  final Exposure exposure;

  ExposureListener({
    Key key,
    this.id,
    this.child,
    this.callback,
    this.loadmore,
    this.scrollDirection,
    this.sliverHeadHeight,
    this.padding,
    this.exposure,
  }) : super(key: key);

  bool _onNotification(context, ScrollNotification notice) {
    LongListProvider<T> longListProvider =
      Provider.of<LongListProvider<T>>(context, listen: false);
    if (notice.metrics.pixels >= notice.metrics.maxScrollExtent - 100) {
      loadmore();
    }
    final sliverMultiBoxAdaptorElement = _findSliverMultiBoxAdaptorElement(notice.context);
    if (sliverMultiBoxAdaptorElement == null) return false;
    int firstIndex = sliverMultiBoxAdaptorElement.childCount;
    assert(firstIndex != null);
    int endIndex = -1;
    final int startTime = DateTime.now().millisecondsSinceEpoch;
    void onVisitChildren(Element element) {
      final SliverMultiBoxAdaptorParentData parentData =
          element?.renderObject?.parentData;
      if (parentData != null) {
        double boundFirst = sliverHeadHeight != null
            ? parentData.layoutOffset + sliverHeadHeight + padding.top
            : parentData.layoutOffset + padding.top;
        double itemLength = scrollDirection == Axis.vertical
            ? element.renderObject.paintBounds.height
            : element.renderObject.paintBounds.width;
        double boundEnd = itemLength + boundFirst;
        if (boundFirst >= notice.metrics.pixels &&
            boundEnd <=
                (notice.metrics.pixels + notice.metrics.viewportDimension)) {
          firstIndex = min(firstIndex, parentData.index);
          endIndex = max(endIndex, parentData.index);
        }
      }
    }
    sliverMultiBoxAdaptorElement.visitChildren(onVisitChildren);
    if (longListProvider.listConfig[id].isLoading && endIndex == longListProvider.list[id].length) {
      endIndex--;
    }
    // print('firstIndex${firstIndex}, endIndex${endIndex}');
    callback(exposure.changeExposure(firstIndex, endIndex, startTime));
    return false;
  }

  SliverMultiBoxAdaptorElement _findSliverMultiBoxAdaptorElement(
      Element element) {
    if (element is SliverMultiBoxAdaptorElement) {
      return element;
    }
    SliverMultiBoxAdaptorElement target;
    element.visitChildElements((child) {
      target ??= _findSliverMultiBoxAdaptorElement(child);
    });
    return target;
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(child: child, onNotification: (_) => _onNotification(context, _));
  }
}

