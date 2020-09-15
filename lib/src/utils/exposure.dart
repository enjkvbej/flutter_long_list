/// 曝光的数据
class ExposureItem {
  final int index;
  int startTime;
  ExposureItem(this.index, this.startTime);
}

/// 要上报的数据
class ToExposureItem {
  final int index;
  final int time;
  ToExposureItem(this.index, this.time);
}

class Exposure {
  // 曝光的list
  List<ExposureItem> exposured = [];
  int lastStartIndex = -1;
  int lastEndIndex = -1;
  
  // 去重
  _removeSame(List<ExposureItem> _total) {
    List<ExposureItem> _totalList = [];
    for (int i = 0; i < _total.length; ++i) {
      bool isRepeat = false;
      for (int j = 0; j < _totalList.length; ++j) {
        if (_totalList[j].index == _total[i].index) {
          isRepeat = true;
        }
      }
      if (isRepeat == false) {
        _totalList.add(_total[i]);
      }
    }
    return _totalList;
  }

  // 是否有数据
  _hasIndex(data, item) {
    return data.indexWhere((val) => val.index == item.index) != -1;
  }

  /// 曝光函数
  List<ToExposureItem> changeExposure(int startIndex, int endIndex, int startTime) {
    final List<ToExposureItem> exposureIndexList = [];
    if (lastStartIndex == startIndex && lastEndIndex == endIndex) {
      return [];
    }
    // 要上报的list
    if (exposured.isNotEmpty) {
      if (exposured[0].index == startIndex && exposured[exposured.length-1].index == endIndex) {
        return [];
      } else {
        List<ExposureItem> newExposured = [];
        for (var i = startIndex; i <= endIndex; ++i) {
          newExposured.add(ExposureItem(i, startTime));
        }
        List<ExposureItem> total = List.from(exposured)..addAll(newExposured);
        List<ExposureItem> totalList = _removeSame(total);
        totalList.forEach((item) {
          if (_hasIndex(exposured, item) && !_hasIndex(newExposured, item)) {
            exposureIndexList.add(ToExposureItem(item.index, startTime - item.startTime));
          }
        });
        exposureIndexList.forEach((item) {
          final index = totalList.indexWhere((val) => val.index == item.index);
          totalList.removeAt(index);
        });
        exposured = totalList;
      }
    } else {
      for (var i = startIndex; i <= endIndex; ++i) {
        exposured.add(ExposureItem(i, startTime));
      }
    }
    lastStartIndex = startIndex;
    lastEndIndex = endIndex;
    return exposureIndexList;
  }
}