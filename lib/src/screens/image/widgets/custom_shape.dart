import 'package:flutter/material.dart';
import 'package:privacyblur/src/screens/image/helpers/constants.dart';
import 'package:privacyblur/src/screens/image/helpers/image_classes_helper.dart';
import 'package:privacyblur/src/widgets/theme/theme_provider.dart';

class ShapePainter extends CustomPainter {
  int _hash = 0;
  final int selectedPosition;
  final List<FilterPosition> positions;

  ShapePainter(this.positions, this.selectedPosition) {
    // with prime numbers to reduce collisions... may be. Not very important
    // from https://primes.utm.edu/lists/small/10000.txt
    for (var p in positions) {
      _hash += (p.isRounded ? 7879 : 9341) +
          selectedPosition * 8467 +
          (p.getVisibleRadius() * 14557).toInt() +
          p.posX +
          p.posY * 12347;
    }
  }

  @override
  bool operator ==(other) {
    return (other is ShapePainter) ? _hash == other._hash : false;
  }

  @override
  int get hashCode => _hash;

  void _drawImageSelection(Canvas canvas, Size size) {
    var paint1 = Paint()
      ..color = AppTheme.primaryColor
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke;
    canvas.drawRect(
        const Offset(0, 0) & Size(size.width - 2, size.height - 2), paint1);
  }

  void _drawCircle(Canvas canvas, int x, int y, int r, Color color) {
    var paint = Paint();
    paint.color = color;
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 2;
    canvas.drawCircle(Offset(x.toDouble(), y.toDouble()), r.toDouble(), paint);
  }

  void _drawRect(
      Canvas canvas, int x, int y, int width, int height, Color color) {
    var paint = Paint();
    paint.color = color;
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 2;
    canvas.drawRect(
        Rect.fromCenter(
            center: Offset(x.toDouble(), y.toDouble()),
            width: width.toDouble(),
            height: height.toDouble()),
        paint);
  }

  void _drawSmallRect(Canvas canvas, Offset center, double r, Color color) {
    var paint = Paint();
    paint.color = color;
    paint.style = PaintingStyle.fill;
    paint.strokeWidth = 1;
    canvas.drawRRect(
        RRect.fromRectAndRadius(
            Rect.fromCircle(center: Offset(center.dx, center.dy), radius: r),
            Radius.circular(r / 3)),
        paint);
    //additional drawing for resizing rect area is here...
  }

  @override
  void paint(Canvas canvas, Size size) {
    positions.asMap().forEach((index, position) {
      if (position.posX <= ImgConst.undefinedPosValue ||
          position.posY <= ImgConst.undefinedPosValue) {
        return;
      }
      var radius = position.getVisibleRadius();
      var colorBorder =
          index == selectedPosition ? AppTheme.primaryColor : Colors.black;
      var colorBorderInner =
          index == selectedPosition ? AppTheme.primaryColor : Colors.grey;
      if (position.isRounded) {
        _drawCircle(canvas, position.posX, position.posY, radius, colorBorder);
        _drawCircle(
            canvas, position.posX, position.posY, radius - 2, colorBorderInner);
      } else {
        _drawRect(
            canvas,
            position.posX,
            position.posY,
            position.getVisibleWidth(),
            position.getVisibleHeight(),
            colorBorder);
        _drawRect(
            canvas,
            position.posX,
            position.posY,
            position.getVisibleWidth() - 2,
            position.getVisibleHeight() - 2,
            colorBorderInner);
      }
      if ((!position.isRounded) && (index == selectedPosition)) {
        _drawSmallRect(canvas, position.getResizingAreaPosition(), radius / 7,
            colorBorder);
      }
    });
    if (selectedPosition < 0 || selectedPosition >= positions.length) {
      _drawImageSelection(canvas, size);
    }
  }

  @override
  bool shouldRepaint(covariant ShapePainter oldDelegate) {
    if (_hash != oldDelegate._hash) {
      return true;
    }
    return false;
  }
}
