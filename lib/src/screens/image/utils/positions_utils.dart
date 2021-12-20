import 'dart:ui';

import 'package:privacyblur/src/data/services/face_detection.dart';
import 'package:privacyblur/src/screens/image/utils/filter_position.dart';

class PositionsUtils {
  /// suppose to return new selected-index after resorting array
  static void markCrossedAreas(List<FilterPosition> arr, int currentIndex) {
    if (currentIndex < 0 || currentIndex >= arr.length) return;
    _markRedraw(arr, currentIndex);
  }

  static int changeAreasDrawOrder(List<FilterPosition> arr, int currentIndex) {
    if (currentIndex < 0 || currentIndex >= arr.length) return currentIndex;
    var position = arr[currentIndex];
    arr.sort((FilterPosition first, FilterPosition second) {
      if (first.isPixelate == second.isPixelate) {
        /// more powerful filter is more important, so we draw on the top
        return ((second.granularityRatio - first.granularityRatio) * 100)
            .toInt();
      } else {
        /// we can add some rules about cross areas if filters are different
        if (first.isPixelate) {
          return ((second.granularityRatio - first.granularityRatio * 1.5) *
                  100)
              .toInt();
        } else {
          return ((second.granularityRatio * 1.5 - first.granularityRatio) *
                  100)
              .toInt();
        }
      }
    });
    currentIndex = arr.indexWhere((element) => identical(element, position));
    return currentIndex;
  }

  static bool checkNewFace(List<FilterPosition> arr, Face face) {
    for (int i = 0; i < arr.length; i++) {
      var pos = arr[i];
      var radiusRatio = face.radius / pos.getVisibleRadius();
      if (radiusRatio > 0.85 && radiusRatio < 1.15) {
        if (pos.isInnerPoint(face.x.toDouble(), face.y.toDouble())) {
          var diffX = (face.x - pos.posX).abs();
          var diffY = (face.y - pos.posY).abs();
          if ((diffX + diffY) < (face.radius * 0.5)) {
            return false;
          }
        }
      }
    }
    return true;
  }

  static bool _checkCross(
      FilterPosition oneFilter, FilterPosition anotherFilter) {
    Rect oneRect = Rect.zero;
    if (oneFilter.isRounded) {
      oneRect = Rect.fromCircle(
          center: Offset(oneFilter.posX, oneFilter.posY),
          radius: oneFilter.getVisibleRadius().toDouble());
    } else {
      oneRect = Rect.fromLTWH(
          oneFilter.posX,
          oneFilter.posY,
          oneFilter.getVisibleWidth().toDouble(),
          oneFilter.getVisibleHeight().toDouble());
    }
    Rect anotherRect = Rect.zero;
    if (anotherFilter.isRounded) {
      anotherRect = Rect.fromCircle(
          center: Offset(anotherFilter.posX, anotherFilter.posY),
          radius: anotherFilter.getVisibleRadius().toDouble());
    } else {
      anotherRect = Rect.fromLTWH(
          anotherFilter.posX,
          anotherFilter.posY,
          anotherFilter.getVisibleWidth().toDouble(),
          anotherFilter.getVisibleHeight().toDouble());
    }
    if (oneRect.contains(anotherRect.center)) return true;
    if (anotherRect.contains(oneRect.center)) return true;

    if (oneRect.contains(anotherRect.topLeft)) return true;
    if (oneRect.contains(anotherRect.topRight)) return true;
    if (oneRect.contains(anotherRect.bottomLeft)) return true;
    if (oneRect.contains(anotherRect.bottomRight)) return true;

    if (anotherRect.contains(oneRect.topLeft)) return true;
    if (anotherRect.contains(oneRect.topRight)) return true;
    if (anotherRect.contains(oneRect.bottomLeft)) return true;
    if (anotherRect.contains(oneRect.bottomRight)) return true;

    return false;
  }

  static void _markRedraw(List<FilterPosition> arr, int currentIndex) {
    if (currentIndex >= arr.length || currentIndex < 0) return;
    var currentFilter = arr[currentIndex];
    for (int i = 0; i < arr.length; i++) {
      if (i == currentIndex) continue;
      var anotherFilter = arr[i];
      if (anotherFilter.forceRedraw) continue;
      if (_checkCross(currentFilter, anotherFilter)) {
        anotherFilter.forceRedraw = true;
        continue;
      }
    }
  }
}
