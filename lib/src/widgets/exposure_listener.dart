import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/rendering.dart';
import '../utils/exposure.dart';

typedef ExposureCallback = void Function(List<ToExposureItem> list);

class ExposureListener extends StatelessWidget {
  final Function loadmore;
  final Widget child;
  final ExposureCallback callback;
  final Axis scrollDirection;
  final double sliverHeadHeight;
  final EdgeInsets padding;
  final Exposure exposure;

  ExposureListener({
    Key key,
    this.child,
    this.callback,
    this.loadmore,
    this.scrollDirection,
    this.sliverHeadHeight,
    this.padding,
    this.exposure,
  }) : super(key: key);

  bool _onNotification(ScrollNotification notice) {
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
      final SliverMultiBoxAdaptorParentData oldParentData =
          element?.renderObject?.parentData;
      if (oldParentData != null) {
        double boundFirst = sliverHeadHeight != null
            ? oldParentData.layoutOffset + sliverHeadHeight + padding.top
            : oldParentData.layoutOffset + padding.top;
        double itemLength = scrollDirection == Axis.vertical
            ? element.renderObject.paintBounds.height
            : element.renderObject.paintBounds.width;
        double boundEnd = itemLength + boundFirst;
        if (boundFirst >= notice.metrics.pixels &&
            boundEnd <=
                (notice.metrics.pixels + notice.metrics.viewportDimension)) {
          firstIndex = min(firstIndex, oldParentData.index);
          endIndex = max(endIndex, oldParentData.index);
        }
      }
    }
    sliverMultiBoxAdaptorElement.visitChildren(onVisitChildren);
    // callback(firstIndex, endIndex, notice);
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
   
    return NotificationListener<ScrollNotification>(child: child, onNotification: _onNotification);
  }
}

