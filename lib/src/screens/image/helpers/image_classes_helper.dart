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

  final int maxRadius;

  FilterPosition(this.maxRadius);

  double _granularity = _sGranularityRatio;
  double _radius = _sRadiusRatio;
  double _cos = cos(pi / 4); //45 degree
  double _sin = sin(pi / 4);

  bool _rounded = _sIsRounded;
  bool _pixelate = _sIsPixelate;

  int posX = ImgConst.undefinedPosValue;
  int posY = ImgConst.undefinedPosValue;

  set setCosinus(double mcos) {
    _cos = mcos;
    if (_cos > 1.0 || _cos < -1.0) {
      _cos = cos(pi / 4);
    }
    _sin = sqrt(1 - pow(_cos, 2));
  }

  double get cosinus => _cos;

  double get sinus => _sin;

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
    var radius = (maxRadius * radiusRatio).toInt();
    return (x <= posX + radius &&
        x >= posX - radius &&
        y <= posY + radius &&
        y >= posY - radius);
  }

  Offset getResizingAreaPosition() {
    if (isRounded) {
      var radius = getVisibleRadius();
      var eX = posX + (radius * _cos);
      var eY = posY - (radius * _sin);
      return Offset(eX, eY);
    } else {
      var radius = getVisibleRadius();
      var eX = posX + (radius * _cos);
      var eY = posY - (radius * _sin);
      return Offset(eX, eY);
    }
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
}
