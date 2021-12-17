import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:privacyblur/src/screens/image/helpers/image_states.dart';
import 'package:privacyblur/src/screens/image/widgets/interactive_viewer_scrollbar.dart';
import 'package:privacyblur/src/utils/image_filter/helpers/filter_result.dart';

import 'interactive_viewer_with_scale.dart';

// ignore: must_be_immutable
class ImageViewer extends StatelessWidget {
  final ImageFilterResult image;
  final ImageStateScreen state;
  final double width; //available width for viewer
  final double height; //available height for viewer
  final void Function(double, double) moveFilterPosition;
  final void Function(double, double) addFilterPosition;
  final void Function(double, double) changeTopRightOffset;
  final void Function(int) selectFilter;
  late TransformationController _transformationController;
  final double maxScale = 10;

  ImageViewer(
      this.image,
      this.state,
      this.width,
      this.height,
      this._transformationController,
      this.moveFilterPosition,
      this.addFilterPosition,
      this.changeTopRightOffset,
      this.selectFilter,
      {Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    var wScale = width / image.mainImage.width;
    var hScale = height / image.mainImage.height;
    double minScale = min(wScale, hScale); //to fit image
    ///initialScale
    ///calculated in parent view once for transformationController
    ///look _calculateInitialScaleAndOffset()
    double initialScale = max(wScale, hScale);

    var imageMinWidth = image.mainImage.width * minScale;
    var imageMinHeight = image.mainImage.height * minScale;

    ///calculate margins for no-scaled image
    double horizontalBorder = ((width - imageMinWidth).abs() / (minScale));
    double verticalBorder = ((height - imageMinHeight).abs() / (minScale));

    return Stack(children: [
      InteractiveViewerWithScale(
        image,
        state,
        _transformationController,
        minScale,
        maxScale,
        initialScale,
        horizontalBorder,
        verticalBorder,
        moveFilterPosition,
        addFilterPosition,
        changeTopRightOffset,
        selectFilter,
      ),
      InteractiveViewerScrollBars(
          controller: _transformationController,
          minScale: minScale,
          maxScale: maxScale,
          initialScale: initialScale,
          imageSize: Size(image.mainImage.width + horizontalBorder,
              image.mainImage.height + verticalBorder),
          viewPortSize: Size(width, height))
    ]);
  }
}
