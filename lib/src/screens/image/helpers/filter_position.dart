import 'dart:math';
import 'dart:ui';

import 'package:flutter/cupertino.dart';

import 'constants.dart';

class FilterPosition {
  /// static filter storage. to keep last created value in memory
  static double _sGranularityRatio = ImgConst.startGranularityRatio;
  static double _sRadiusRatio = ImgConst.startRadiusRatio;
  static bool _sIsRounded = true;
  static bool _sIsPixelate = true;
  static double _sSin = sin(pi / 4);
  static double _sCos = cos(pi / 4);

  final int maxRadius;

  FilterPosition(this.maxRadius);

  double _granularity = _sGranularityRatio;
  double _radius = _sRadiusRatio;
  double _cos = _sCos; //45 degree
  double _sin = _sSin;

  bool _rounded = _sIsRounded;
  bool _pixelate = _sIsPixelate;

  int posX = ImgConst.undefinedPosValue;
  int posY = ImgConst.undefinedPosValue;

  set granularityRatio(double value) {
    _granularity = value;
    _sGranularityRatio = value;
  }

  double get granularityRatio => _granularity;

  set radiusRatio(double value) {
    _radius = value;
    _sRadiusRatio = value;
  }

  double get radiusRatio => _radius;

  set isRounded(bool value) {
    _rounded = value;
    _sIsRounded = value;
  }

  bool get isRounded => _rounded;

  set isPixelate(bool value) {
    _pixelate = value;
    _sIsPixelate = value;
  }

  bool get isPixelate => _pixelate;

  bool canceled = true;
  bool forceRedraw = true;

  int getVisibleRadius() => (maxRadius * radiusRatio).toInt();

  int getVisibleWidth() => (maxRadius * radiusRatio * _cos * 2).toInt();

  int getVisibleHeight() => (maxRadius * radiusRatio * _sin * 2).toInt();

  bool isInnerPoint(int x, int y) {
    var radius = getVisibleRadius();
    if (_rounded) {
      return sqrt(pow(posX - x, 2) + pow(posY - y, 2)) <= getVisibleRadius();
    } else {
      var diffx = radius * _cos;
      var diffY = radius * _sin;
      return (x <= posX + diffx &&
          x >= posX - diffx &&
          y <= posY + diffY &&
          y >= posY - diffY);
    }
  }

  Offset getResizingAreaPosition() {
    var radius = getVisibleRadius();
    var eX = posX + (radius * _cos);
    var eY = posY - (radius * _sin);
    return Offset(eX, eY);
  }

  bool isResizingAreaPoint(double x, double y) {
    var offset = getResizingAreaPosition();
    var clickRadius = getVisibleRadius() ~/ 5; // detect click area radius
    var eX = offset.dx;
    var eY = offset.dy;
    return (x <= eX + clickRadius &&
        x >= eX - clickRadius &&
        y <= eY + clickRadius &&
        y >= eY - clickRadius);
  }

  void rebuildRadiusFromClick(double x2, double y2) {
    var diffx = x2 - posX;
    var diffy = posY - y2;
    var dist = sqrt(pow(diffx, 2) + pow(diffy, 2));
    _cos = diffx / dist;
    _sin = diffy / dist;
    /*_sCos = _cos; //we will not save this for new areas always new squares and circles
    _sSin = _sin;*/
    radiusRatio = dist / maxRadius;
    if (radiusRatio > 1.0) radiusRatio = 1.0;
  }
}
