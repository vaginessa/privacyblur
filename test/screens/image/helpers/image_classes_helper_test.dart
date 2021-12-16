import 'package:flutter_test/flutter_test.dart';
import 'package:privacyblur/src/screens/image/helpers/constants.dart';
import 'package:privacyblur/src/screens/image/helpers/filter_position.dart';

void main() {
  /// --- UserInfo ---
  test('base function', () {
    var filter = FilterPosition(100);
    expect(filter.posX, ImgConst.undefinedPosValue);
    expect(filter.posY, ImgConst.undefinedPosValue);
    expect(filter.radiusRatio, ImgConst.startRadiusRatio);
    expect(filter.maxRadius, 100);
    expect(
        filter.getVisibleRadius(), (ImgConst.startRadiusRatio * 100).round());
    filter.posX = 50;
    filter.posY = 50;
    var resize = filter.getResizingAreaPosition();
    expect(resize.dx.round(), 75);
    expect(resize.dy.round(), 25);
    filter.rebuildRadiusFromClick(80, 80);
    resize = filter.getResizingAreaPosition();
    expect(resize.dx.round(), 80);
    expect(resize.dy.round(), 80);
    expect(filter.getVisibleRadius(), 42);
  });
}
