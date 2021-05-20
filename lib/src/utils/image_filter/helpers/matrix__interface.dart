import 'image_rgb.dart';
import 'range_checker.dart';

abstract class ImageAppMatrix {
  int emptyBorder();

  void calculateInRange(RangeHelper range, ImageRGB channels);
}
