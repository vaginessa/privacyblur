import 'dart:typed_data';

import 'package:flutter/services.dart';

class Face {
  final double x;
  final double y;
  final double radius;

  Face(this.x, this.y, this.radius);
}

typedef Faces = List<Face>;

class FaceDetection {
  static const _platform =
      const MethodChannel('de.mathema.privacyblur/face_detection');

  FaceDetection._privateConstructor();

  static final FaceDetection _instance = FaceDetection._privateConstructor();

  factory FaceDetection() {
    return _instance;
  }

  Future<Faces> detectFaces(
      Uint8List rawImageData, int width, int height) async {
    try {
      var result = await _platform.invokeMethod('detectFaces',
          {'argb8': rawImageData, 'width': width, 'height': height});
      return Future.value([]);
    } catch (err) {
      return Future.value([]);
    }
  }
}
