import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:privacyblur/src/screens/image/helpers/image_states.dart';
import 'package:privacyblur/src/utils/image_filter/helpers/filter_result.dart';

import 'custom_painter.dart';
import 'custom_shape.dart';

// ignore: must_be_immutable
class ImageViewer extends StatelessWidget {
  final ImageFilterResult image;
  final ImageStateScreen state;
  final double width; //available width for viewer
  final double height; //available height for viewer
  final void Function(double, double) setFilterPosition;
  late double radiusSize;
  late TransformationController _transformationController;

  ImageViewer(this.image, this.state, this.width, this.height,
      this._transformationController, this.setFilterPosition);

  @override
  Widget build(BuildContext context) {
    radiusSize = state.radiusRatio * state.maxRadius;
    var wScale = width / image.mainImage.width;
    var hScale = height / image.mainImage.height;
    var minScale = min(wScale, hScale); //to fit image
    ///initialScale
    ///calculated in parent view once for transformationController
    ///look _calculateInitialScaleAndOffset()
    var initialScale = max(wScale, hScale);
    var imageMinWidth = image.mainImage.width * minScale;
    var imageMinHeight = image.mainImage.height * minScale;

    ///calculate margins for no-scaled image
    var horizontalBorder = ((width - imageMinWidth).abs() / (minScale));
    var verticalBorder = ((height - imageMinHeight).abs() / (minScale));
    EdgeInsets boundaryMargin =
        EdgeInsets.fromLTRB(0, 0, horizontalBorder, verticalBorder);

    return GestureDetector(
      onTapUp: onSetFilterPosition,
      onLongPressMoveUpdate: onDragFilter,
      onLongPressStart: onDragStartFilter,
      child: InteractiveViewer(
          transformationController: _transformationController,
          maxScale: 10,
          scaleEnabled: true,
          panEnabled: true,
          constrained: false,
          boundaryMargin: boundaryMargin,
          minScale: minScale / initialScale,
          child: SizedBox(
              width: image.mainImage.width.toDouble(),
              height: image.mainImage.height.toDouble(),
              child: CustomPaint(
                size: Size(image.mainImage.height.toDouble(),
                    image.mainImage.width.toDouble()),
                isComplex: true,
                willChange: true,
                painter: ImgPainter(image),
                foregroundPainter: ShapePainter(
                    state.posX, state.posY, radiusSize, state.isRounded),
              ))),
    );
  }

  onSetFilterPosition(TapUpDetails details) {
    Offset offset = _transformationController.toScene(
      details.localPosition,
    );
    setFilterPosition(offset.dx, offset.dy);
  }

  onDragFilter(LongPressMoveUpdateDetails details) {
    _setFilterDragPos(_transformationController.toScene(
      details.localPosition,
    ));
  }

  onDragStartFilter(LongPressStartDetails details) {
    _setFilterDragPos(_transformationController.toScene(
      details.localPosition,
    ));
  }

  void _setFilterDragPos(Offset offset) {
    if (_calulateDragInArea(offset)) {
      setFilterPosition(offset.dx, offset.dy);
    }
  }

  bool _calulateDragInArea(Offset offset) {
    double dist;
    double distX = pow((state.posX.toDouble() - offset.dx), 2).abs().toDouble();
    double distY = pow((state.posY.toDouble() - offset.dy), 2).abs().toDouble();
    if (state.isRounded) {
      dist = sqrt(distY + distX);
      return dist <= radiusSize;
    } else {
      dist = distY + distX;
      return dist <= pow(radiusSize, 2);
    }
  }
}
