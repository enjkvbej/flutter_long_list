import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/rendering.dart';
import '../utils/exposure.dart';

typedef ExposureCallback = void Function(List<ToExposureItem> list);
typedef ExposureReferee = bool Function(
    ExposureStartIndex index, double paintExtent, double maxPaintExtent);
class IndexRange {
  // 父节点下标
  final int parentIndex;
  // 第一个可见的元素下标
  final int firstIndex;
  // 最后一个可见元素下标
  final int lastIndex;
  IndexRange(this.parentIndex, this.firstIndex, this.lastIndex);
}
class ExposureStartIndex {
  // 父节点下标
  final int parentIndex;

  // 曝光子节点下标
  final int itemIndex;

  // 曝光开始事件
  final int exposureStartTime;

  ExposureStartIndex(this.parentIndex, this.itemIndex, this.exposureStartTime);
}

class _Point {
  final int parentIndex;
  final int itemIndex;
  final int time;

  _Point(this.parentIndex, this.itemIndex, this.time);

  @override
  bool operator ==(other) {
    if (other is! _Point) {
      return false;
    }
    return this.parentIndex == other.parentIndex &&
        this.itemIndex == other.itemIndex;
  }

  @override
  int get hashCode => hashValues(parentIndex, itemIndex);
}
class MultiExposureListener extends StatelessWidget {
  final Function loadmore;
  final Widget child;
  final ExposureCallback callback;
  final Axis scrollDirection;
  final double sliverHeadHeight;
  final EdgeInsets padding;
  final Exposure exposure;
  Set<_Point> visibleSet = Set();
  Set<_Point> oldSet;

  MultiExposureListener({
    Key key,
    this.child,
    this.callback,
    this.loadmore,
    this.scrollDirection,
    this.sliverHeadHeight,
    this.padding,
    this.exposure,
  }) : super(key: key);

  IndexRange _visitSliverMultiBoxAdaptorElement(
      SliverMultiBoxAdaptorElement sliverMultiBoxAdaptorElement,
      double portF,
      double portE,
      Axis axis,
      ExposureReferee exposureReferee,
      int exposureTime,
      int parentIndex) {
    if (sliverMultiBoxAdaptorElement == null) return null;
    int firstIndex = sliverMultiBoxAdaptorElement.childCount;
    assert(firstIndex != null);
    int endIndex = -1;
    void onVisitChildren(Element element) {
      final SliverMultiBoxAdaptorParentData parentData =
          element?.renderObject?.parentData;
          // print('parentIndex${parentIndex}');
          // print('parentData${parentData.index}');
      if (parentData != null) {
        double boundF = sliverHeadHeight != null ? parentData.layoutOffset + sliverHeadHeight : parentData.layoutOffset;
        double itemLength = axis == Axis.vertical
            ? element.renderObject.paintBounds.height
            : element.renderObject.paintBounds.width;
        double boundE = itemLength + boundF;
        double paintExtent = max(min(boundE, portE) - max(boundF, portF), 0);
        double maxPaintExtent = itemLength;
        bool isExposure = exposureReferee != null
            ? exposureReferee(
                ExposureStartIndex(parentIndex, parentData.index, exposureTime),
                paintExtent,
                maxPaintExtent)
            : paintExtent == maxPaintExtent;
 
        if (isExposure) {
          firstIndex = min(firstIndex, parentData.index);
          endIndex = max(endIndex, parentData.index);
        }
      }
    }
    
    sliverMultiBoxAdaptorElement.visitChildren(onVisitChildren);
    // print('parentIndex${parentIndex}, firstIndex${firstIndex}, endIndex${endIndex}');
    return IndexRange(parentIndex, firstIndex, endIndex);
  }

  bool _onNotification(ScrollNotification notice) {
    if (notice.metrics.pixels >= notice.metrics.maxScrollExtent - 100) {
      loadmore();
    }
    // 记录当前曝光时间，可作为开始曝光元素的曝光开始时间点和结束曝光节点的结束曝光时间点
    final int exposureTime = DateTime.now().millisecondsSinceEpoch;
    // 查找对应的Viewport节点MultiChildRenderObjectElement
    final viewPortElement =
        findElementByType<MultiChildRenderObjectElement>(notice.context);
    assert(viewPortElement != null);
    // 定义parentIndex 用于确定外层节点位置，也作为SliverList或SlierGrid的parentIndex
    int parentIndex = 0;
    final indexRanges = <IndexRange>[];
    // // 保存上次完全可见的集合用于之后的结束曝光通知
    oldSet = Set.from(visibleSet);
    // 每个节点前面所有节点所占的范围，用于SliverList或SliverGrid确定
    // 自身在viewport中的可见区域
    double totalScrollExtent = 0;
    viewPortElement.visitChildElements((itemElement) {
      assert(itemElement.renderObject is RenderSliver);
      final geometry = (itemElement.renderObject as RenderSliver).geometry;
      // 判断当前子节点时是否可见，不可见无须处理曝光
      if (geometry.visible) {
        if (itemElement is SliverMultiBoxAdaptorElement) {
          // SliverList和SliverGrid进行子节点曝光判断
          
          final indexRange = _visitSliverMultiBoxAdaptorElement(
              itemElement,
              notice.metrics.pixels - totalScrollExtent,
              notice.metrics.pixels - totalScrollExtent + geometry.paintExtent,
              scrollDirection,
              (ExposureStartIndex index, double paintExtent,
                  double maxPaintExtent) {
                return paintExtent == maxPaintExtent;
              },
              exposureTime,
              parentIndex);
          indexRanges.add(indexRange);

          _dispatchExposureStartEventByIndexRange(indexRange, exposureTime);
        }
        totalScrollExtent += geometry.scrollExtent;
        parentIndex++;
      }
      
    });
    // print(indexRanges);
    // // 根据上次曝光的元素集合找出当前已不可见的元素，进行曝光结束事件通过
    _dispatchExposureEndEvent(oldSet, exposureTime);
    // // 调用scrollCallback返回当前可见元素位置
    // widget.scrollCallback?.call(indexRanges, notice);
    return false;
  }
  
  void _dispatchExposureStartEventByIndexRange(
      IndexRange indexRange, int exposureTime) {
    if (indexRange.firstIndex > indexRange.lastIndex) {
      return;
    }
    for (int i = indexRange.firstIndex; i <= indexRange.lastIndex; i++) {
      _dispatchExposureStartEvent(indexRange.parentIndex, i, exposureTime);
    }
  }

  void _dispatchExposureStartEvent(int parentIndex, int itemIndex, int exposureTime) {
    final point = _Point(parentIndex, itemIndex, exposureTime);
    if (!visibleSet.contains(point)) {
      visibleSet.add(point);
      // widget.exposureStartCallback
      //     ?.call(ExposureStartIndex(parentIndex, itemIndex, exposureTime));
    } else {
      oldSet.remove(point);
    }
  }

  void _dispatchExposureEndEvent(Set<_Point> set, int exposureTime) {
    List<ToExposureItem> toExposureList = [];
    set.forEach((item) {
      if (sliverHeadHeight != null) {
        if (item.parentIndex == 1) {
          print('${item.parentIndex}, ${item.itemIndex}, ${exposureTime}, ${exposureTime - item.time}');
          toExposureList.add(ToExposureItem(item.itemIndex, exposureTime - item.time));
        }
      } else {
        if (item.parentIndex == 0) {
          print('${item.parentIndex}, ${item.itemIndex}, ${exposureTime}, ${exposureTime - item.time}');
          toExposureList.add(ToExposureItem(item.itemIndex, exposureTime - item.time));
        }
      }
    });
    callback(toExposureList);
    if (visibleSet == set) {
      visibleSet.clear();
    } else {
      visibleSet.removeAll(set);
    }
  }

  T findElementByType<T extends Element>(Element element) {
    if (element is T) {
      return element;
    }
    T target;
    element.visitChildElements((child) {
      target ??= findElementByType<T>(child);
    });
    return target;
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(child: child, onNotification: _onNotification);
  }
}