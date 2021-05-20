import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:ui' as img_tools;

import 'package:image_size_getter/file_input.dart';
import 'package:image_size_getter/image_size_getter.dart';

class ImgTools {
  int srcWidth = 0;
  int srcHeight = 0;
  bool scaled = false;

  Future<img_tools.Image> scaleFile(File file, int maxSize) async {
    scaled = false;
    if (maxSize <= 0) return readFile(file);
    maxSize = (maxSize ~/ 16) * 16;
    Size size;
    size = ImageSizeGetter.getSize(FileInput(file));
    srcWidth = size.width;
    srcHeight = size.height;
    if (srcWidth < 0 || srcHeight < 0) {
      throw FormatException('Wrong image format');
    }

    var scaleRatio = max(srcWidth, srcHeight) / maxSize;
    if (scaleRatio > 1.0) {
      scaled = true;
      var codec = await img_tools.instantiateImageCodec(file.readAsBytesSync(),
          allowUpscaling: false,
          targetWidth: srcWidth ~/ scaleRatio,
          targetHeight: srcHeight ~/ scaleRatio);
      var frame = await codec.getNextFrame();
      return Future.value(frame.image);
    } else {
      return readFile(file);
    }
  }

  Future<img_tools.Image> readFile(File file) async {
    var completer = Completer<img_tools.Image>();
    img_tools.decodeImageFromList(file.readAsBytesSync(), (result) {
      completer.complete(result);
    });
    var tempImage = await completer.future;
    srcWidth = tempImage.width;
    srcHeight = tempImage.height;
    scaled = false;
    return Future.value(tempImage);
  }
}
