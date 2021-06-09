import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:privacyblur/src/screens/image/helpers/image_states.dart';
import 'package:privacyblur/src/utils/image_filter/helpers/filter_result.dart';

import 'custom_painter.dart';
import 'custom_shape.dart';

// ignore: must_be_immutable
class ImageViewer extends StatefulWidget {
  final ImageFilterResult image;
  final ImageStateScreen state;
  final double width; //available width for viewer
  final double height; //available height for viewer
  final void Function(double, double) moveFilterPosition;
  final void Function(double, double) addFilterPosition;
  final void Function(int) selectFilter;
  late TransformationController _transformationController;

  ImageViewer(
      this.image,
      this.state,
      this.width,
      this.height,
      this._transformationController,
      this.moveFilterPosition,
      this.addFilterPosition,
      this.selectFilter
  );

  @override
  _ImageViewerState createState() => _ImageViewerState();
}

class _ImageViewerState extends State<ImageViewer> {
  final double maxScale = 10;
  late Size _scrollBarSize;
  late Offset _transformationOffset;
  late double minScale;
  late EdgeInsets boundaryMargin;
  late double horizontalBorder;
  late double verticalBorder;
  late double initialScale;
  late double canvasViewportWidthRatio;
  late double canvasViewportHeightRatio;

  @override
  void initState() {
    var wScale = widget.width / widget.image.mainImage.width;
    var hScale = widget.height / widget.image.mainImage.height;
    minScale = min(wScale, hScale); //to fit image
    ///initialScale
    ///calculated in parent view once for transformationController
    ///look _calculateInitialScaleAndOffset()
    initialScale = max(wScale, hScale);
    var imageMinWidth = widget.image.mainImage.width * minScale;
    var imageMinHeight = widget.image.mainImage.height * minScale;
    ///calculate margins for no-scaled image
    horizontalBorder = ((widget.width - imageMinWidth).abs() / (minScale));
    verticalBorder = ((widget.height - imageMinHeight).abs() / (minScale));
    boundaryMargin =
    EdgeInsets.fromLTRB(0, 0, horizontalBorder, verticalBorder);

    widget._transformationController.addListener(() =>
        _calculateTransformationUpdates(
            widget._transformationController.value));
    _calculateTransformationUpdates(widget._transformationController.value);
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GestureDetector(
          onTapUp: onTapPosition,
          onLongPressMoveUpdate: onMoveFilter,
          onLongPressStart: onLongPressStart,
          child: InteractiveViewer(
              transformationController: widget._transformationController,
              maxScale: maxScale,
              scaleEnabled: true,
              panEnabled: true,
              constrained: false,
              boundaryMargin: boundaryMargin,
              minScale: minScale / initialScale,
              child: SizedBox(
                width: widget.image.mainImage.width.toDouble(),
                height: widget.image.mainImage.height.toDouble(),
                child: CustomPaint(
                  size: Size(widget.image.mainImage.height.toDouble(),
                      widget.image.mainImage.width.toDouble()),
                  isComplex: true,
                  willChange: true,
                  painter: ImgPainter(widget.image),
                  foregroundPainter: ShapePainter(widget.state.positions,
                      widget.state.selectedFilterIndex),
                )))),
        Positioned(
          bottom: 0,
          left: _transformationOffset.dx,
          child: Container(
            height: 5,
            width: _scrollBarSize.width,
            decoration: BoxDecoration(
              color: Colors.blueGrey,
              borderRadius: BorderRadius.all(Radius.circular(10))
            ),
          ),
        ),
        Positioned(
          top: _transformationOffset.dy,
          right: 0,
          child: Container(
            height: _scrollBarSize.height,
            width: 5,
            decoration: BoxDecoration(
                color: Colors.blueGrey,
                borderRadius: BorderRadius.all(Radius.circular(10))
            ),
          ),
        ),
      ]
    );
  }

  void _calculateTransformationUpdates(Matrix4 matrix) {
    double offsetX = widget._transformationController.value.row0[3];
    double offsetY = widget._transformationController.value.row1[3];
    double currentScale = widget._transformationController.value.row0[0];
    double transformationScale = 1 - (((currentScale - minScale) * 0.9) / (maxScale * initialScale - minScale));

    /// If fully zoomed out then must equal full screen size
    double horizontalScrollbarSize = widget.width * transformationScale;
    double verticalScrollbarSize = widget.height * transformationScale;

    double scrollBarOffsetX = ((offsetX / currentScale) / ((widget.image.mainImage.width + horizontalBorder) - widget.width / currentScale)).abs() * (widget.width - horizontalScrollbarSize);
    double scrollBarOffsetY = ((offsetY / currentScale) / ((widget.image.mainImage.height + verticalBorder) - widget.height / currentScale)).abs() * (widget.height - verticalScrollbarSize);
    setState(() {
      _scrollBarSize = Size(horizontalScrollbarSize, verticalScrollbarSize);
      _transformationOffset = Offset(scrollBarOffsetX, scrollBarOffsetY);
    });
  }

  onTapPosition(TapUpDetails details) {
    Offset offset = widget._transformationController.toScene(
      details.localPosition,
    );
    var selected = _detectSelectedFilter(offset);
    if (selected >= 0) {
      widget.selectFilter(selected);
    } else {
      widget.addFilterPosition(offset.dx, offset.dy);
    }
  }

  onMoveFilter(LongPressMoveUpdateDetails details) {
    Offset offset = widget._transformationController.toScene(
      details.localPosition,
    );
    if (widget.state.hasSelection) {
      widget.moveFilterPosition(offset.dx, offset.dy);
    }
  }

  onLongPressStart(LongPressStartDetails details) {
    Offset offset = widget._transformationController.toScene(
      details.localPosition,
    );
    var selected = _detectSelectedFilter(offset);
    widget.selectFilter(selected);
    if (selected >= 0) {
      widget.moveFilterPosition(offset.dx, offset.dy);
    }
  }

  int _detectSelectedFilter(Offset offset) {
    int index = -1;
    double dist = 10000000;
    widget.state.positions.asMap().forEach((key, value) {
      var tmpRadius = widget.state.maxRadius * value.radiusRatio;
      var tmp =
          sqrt(pow(value.posX - offset.dx, 2) + pow(value.posY - offset.dy, 2));
      if ((value.isRounded && (tmp <= tmpRadius)) ||
          ((!value.isRounded) &&
              ((value.posX - offset.dx).abs() <= tmpRadius) &&
              ((value.posY - offset.dy).abs() <= tmpRadius))) {
        if (tmp < dist) {
          index = key;
          dist = tmp;
        }
      }
    });
    return index;
  }
}
