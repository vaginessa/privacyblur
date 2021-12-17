import 'package:flutter_test/flutter_test.dart';
import 'package:privacyblur/src/screens/image/helpers/constants.dart';
import 'package:privacyblur/src/screens/image/helpers/filter_position.dart';

void main() {
  /// --- UserInfo ---
  test('base function rounded areas', () {
    FilterPosition.resetStoredInfo();
    var filter = FilterPosition(100);
    filter.isRounded = true; //circle
    expect(filter.posX, ImgConst.undefinedPosValue.toDouble());
    expect(filter.posY, ImgConst.undefinedPosValue.toDouble());
    expect(filter.radiusRatio, ImgConst.startRadiusRatio);
    expect(filter.maxRadius, 100);
    expect(
        filter.getVisibleRadius(), (ImgConst.startRadiusRatio * 100).round());
    filter.posX = 50;
    filter.posY = 50;
    var resize = filter.getResizingAreaPosition();
    expect(resize.dx.round(), 75);
    expect(resize.dy.round(), 75);
    filter.rebuildRadiusFromClick(80, 80);
    resize = filter.getResizingAreaPosition();
    expect(resize.dx.round(), 80);
    expect(resize.dy.round(), 80);
    expect(filter.getVisibleRadius(), 42);
  });

  test('base function squared areas', () {
    FilterPosition.resetStoredInfo();
    var filter = FilterPosition(100);
    filter.isRounded = false; //square
    expect(filter.posX, ImgConst.undefinedPosValue.toDouble());
    expect(filter.posY, ImgConst.undefinedPosValue.toDouble());
    expect(filter.radiusRatio, ImgConst.startRadiusRatio);
    expect(filter.maxRadius, 100);
    expect(
        filter.getVisibleRadius(), (ImgConst.startRadiusRatio * 100).round());
    filter.posX = 50;
    filter.posY = 50;
    var resize = filter.getResizingAreaPosition();
    expect(resize.dx.round(), 75);
    expect(resize.dy.round(), 75);
    filter.rebuildRadiusFromClick(80, 80);
    resize = filter.getResizingAreaPosition();
    expect(filter.posX.toInt(), 52);
    expect(filter.posY.toInt(), 52);
    expect(filter.getVisibleRadius(), 38);
  });
}
