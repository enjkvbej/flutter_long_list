// 曝光的数据
class ExposureItem {
  final int index;
  int startTime;
  ExposureItem(this.index, this.startTime);
}

// 要上报的数据
class ToExposureItem {
  final int index;
  final int time;
  ToExposureItem(this.index, this.time);
}

class Exposure {
  // 曝光的list
  List<ExposureItem> exposured = [];

  List<ToExposureItem> changeExposure(int startIndex, int endIndex, int startTime) {
    // 要上报的list
    final List<ToExposureItem> exposureIndexList = [];
    if (exposured.isNotEmpty) {
      if (exposured[0].index == startIndex && exposured[exposured.length-1].index == endIndex) {
        print('==');
        return exposureIndexList;
      } else {
        for (var i = startIndex; i <= endIndex; ++i) {
          if (i > exposured.length) {
            exposured.add(ExposureItem(i, startTime));
          }
        }
        exposured.forEach((item) {
          if (item.index < startIndex) {
            exposureIndexList.add(ToExposureItem(item.index, startTime - item.startTime));
          }
        });
        exposureIndexList.forEach((item) {
          final index = exposured.indexWhere((val) => val.index == item.index);
          exposured.removeAt(index);
          print('delete后${exposured.length}');
        });
      }
    } else {
      for (var i = startIndex; i <= endIndex; ++i) {
        exposured.add(ExposureItem(i, startTime));
      }
    }
    print(exposureIndexList.asMap());
    return exposureIndexList;
  }
}