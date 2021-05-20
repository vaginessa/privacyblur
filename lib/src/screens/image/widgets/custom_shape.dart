import 'package:flutter/material.dart';
import 'package:privacyblur/src/screens/image/helpers/constants.dart';

class ShapePainter extends CustomPainter {
  static int _old_hash = 0;
  late int _hash;
  final double radius;
  final bool isRounded;
  final int x, y;

  ShapePainter(this.x, this.y, this.radius, this.isRounded) {
    // with prime numbers to reduce collisions... may be. Not very important
    // from https://primes.utm.edu/lists/small/10000.txt
    _hash =
        (isRounded ? 7879 : 9341) + (radius * 14557).toInt() + x + y * 12347;
  }

  @override
  bool operator ==(other) {
    return (other is ShapePainter) ? this._hash == other._hash : false;
  }

  @override
  int get hashCode => _hash;

  void _drawCircle(Canvas canvas, double r, Color color) {
    var paint = Paint();
    paint.color = color;
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 2;
    canvas.drawCircle(Offset(x.toDouble(), y.toDouble()), r.toDouble(), paint);
  }

  void _drawRect(Canvas canvas, double r, Color color) {
    var paint = Paint();
    paint.color = color;
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 2;
    canvas.drawRect(
        Rect.fromCircle(
            center: Offset(x.toDouble(), y.toDouble()), radius: r.toDouble()),
        paint);
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (x <= ImgConst.undefinedPosValue || y <= ImgConst.undefinedPosValue) {
      return;
    }
    if (isRounded) {
      _drawCircle(canvas, radius, Colors.black);
      _drawCircle(canvas, radius - 2, Colors.grey);
    } else {
      _drawRect(canvas, radius, Colors.black);
      _drawRect(canvas, radius - 2, Colors.grey);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    int newHash = hashCode;
    if (newHash != _old_hash) {
      _old_hash = newHash;
      return true;
    }
    return false;
  }
}
