import 'dart:math';
import 'dart:ui';

import 'package:flutter/cupertino.dart';

import '../helpers/constants.dart';

class FilterPosition {
  /// static filter storage. to keep last created value in memory
  static double _sGranularityRatio = ImgConst.startGranularityRatio;
  static double _sRadiusRatio = ImgConst.startRadiusRatio;
  static bool _sIsRounded = true;
  static bool _sIsPixelate = true;

  // todo - for tests we need to reset class to inital values
  // todo - but better to use some provider in future and mock it in tests
  static void resetStoredInfo() {
    _sGranularityRatio = ImgConst.startGranularityRatio;
    _sRadiusRatio = ImgConst.startRadiusRatio;
    _sIsRounded = true;
    _sIsPixelate = true;
  }

  /// scale area constants
  static const _startAngle = -pi / 4; //bottom right point
  static final double _sSin = sin(_startAngle);
  static final double _sCos = cos(_startAngle);
  static const _resizeBlockSize = 8; //dp//lp

  final int maxRadius;

  FilterPosition(this.maxRadius);

  double _granularity = _sGranularityRatio;
  double _radius = _sRadiusRatio;
  double _cos = _sCos; //45 degree
  double _sin = _sSin;

  bool _rounded = _sIsRounded;
  bool _pixelate = _sIsPixelate;

  double posX = ImgConst.undefinedPosValue.toDouble();
  double posY = ImgConst.undefinedPosValue.toDouble();

  set granularityRatio(double value) {
    _granularity = value;
    _sGranularityRatio = value;
  }

  double get granularityRatio => _granularity;

  set radiusRatio(double value) {
    _radius = value;
    _sRadiusRatio = value;
    if (!_rounded) {
      _sRadiusRatio = ((_radius * _cos).abs() + (_radius * _sin).abs()) / 2.0;
    }
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

  bool isInnerPoint(double x, double y) {
    var radius = getVisibleRadius();
    if (_rounded) {
      return sqrt(pow(posX - x, 2) + pow(posY - y, 2)) <=
          (getVisibleRadius() + 0.51);
    } else {
      var diffX = (radius * _cos).abs() + 0.51;
      var diffY = (radius * _sin).abs() + 0.51;
      return (x <= posX + diffX &&
          x >= posX - diffX &&
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

  Rect getResizingAreaRect(double pixelsInDP) {
    return Rect.fromCenter(
        center: getResizingAreaPosition(),
        width: _resizeBlockSize * pixelsInDP,
        height: _resizeBlockSize * pixelsInDP);
  }

  void rebuildRadiusFromClick(double x2, double y2) {
    if (_rounded) {
      var diffx = x2 - posX;
      var diffy = posY - y2;
      var dist = sqrt(pow(diffx, 2) + pow(diffy, 2));
      _cos = diffx / dist;
      _sin = diffy / dist;
      /*_sCos = _cos; //we will not save this for new areas always new squares and circles
      _sSin = _sin;*/
      radiusRatio = dist / maxRadius;
      if (radiusRatio > 1.0) radiusRatio = 1.0;
    } else {
      var diffx = x2 - (posX - (maxRadius * radiusRatio * _cos));
      var diffy = (posY + (maxRadius * radiusRatio * _sin)) - y2;
      var dist = sqrt(pow(diffx, 2) + pow(diffy, 2));
      posX = (2 * x2 - diffx) / 2;
      posY = (diffy + 2 * y2) / 2;
      _cos = diffx / dist;
      _sin = diffy / dist;
      radiusRatio = dist / (maxRadius * 2);
      if (radiusRatio > 1.0) radiusRatio = 1.0;
    }
  }
}
