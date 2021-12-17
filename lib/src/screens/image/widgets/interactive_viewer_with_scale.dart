import 'dart:math';

import 'package:flutter/widgets.dart';
import 'package:privacyblur/src/screens/image/helpers/filter_position.dart';
import 'package:privacyblur/src/screens/image/helpers/image_states.dart';
import 'package:privacyblur/src/utils/image_filter/helpers/filter_result.dart';

import 'painter_image.dart';
import 'painter_shape.dart';

class InteractiveViewerWithScale extends StatefulWidget {
  final TransformationController controller;
  final double minScale;
  final double maxScale;
  final double initialScale;
  final double horizontalBorder;
  final double verticalBorder;
  final ImageFilterResult image;
  final ImageStateScreen extState;
  final void Function(double, double) moveFilterPosition;
  final void Function(double, double) addFilterPosition;
  final void Function(double, double) changeTopRightOffset;
  final void Function(int) selectFilter;

  const InteractiveViewerWithScale(
      this.image,
      this.extState,
      this.controller,
      this.minScale,
      this.maxScale,
      this.initialScale,
      this.horizontalBorder,
      this.verticalBorder,
      this.moveFilterPosition,
      this.addFilterPosition,
      this.changeTopRightOffset,
      this.selectFilter,
      {Key? key})
      : super(key: key);

  @override
  _InteractiveViewerWithScaleState createState() =>
      _InteractiveViewerWithScaleState();
}

class _InteractiveViewerWithScaleState
    extends State<InteractiveViewerWithScale> {
  double imgPixelsInDP = 1.0;
  double devicePixelsInDP = 1.0;
  late final void Function() listenerCallback = _calculateScaleUpdate;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    devicePixelsInDP = MediaQuery.of(context).devicePixelRatio;
    widget.controller.removeListener(listenerCallback);
    widget.controller.addListener(listenerCallback);
    _calculateScaleUpdate();
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    EdgeInsets boundaryMargin = EdgeInsets.fromLTRB(
        0, 0, widget.horizontalBorder, widget.verticalBorder);
    return GestureDetector(
        onTapUp: onTapPosition,
        onLongPressMoveUpdate: onLongMove,
        onLongPressStart: onLongPressStart,
        child: InteractiveViewer(
            transformationController: widget.controller,
            maxScale: widget.maxScale,
            scaleEnabled: true,
            panEnabled: true,
            constrained: false,
            boundaryMargin: boundaryMargin,
            minScale: widget.minScale,
            child: SizedBox(
                width: widget.image.mainImage.width.toDouble(),
                height: widget.image.mainImage.height.toDouble(),
                child: CustomPaint(
                  size: Size(widget.image.mainImage.height.toDouble(),
                      widget.image.mainImage.width.toDouble()),
                  isComplex: true,
                  willChange: true,
                  painter: ImgPainter(widget.image),
                  foregroundPainter: ShapePainter(widget.extState.positions,
                      widget.extState.selectedFilterIndex, imgPixelsInDP),
                ))));
  }

  onTapPosition(TapUpDetails details) {
    Offset offset = widget.controller.toScene(
      details.localPosition,
    );
    var selected = _detectSelectedFilter(offset);
    if (selected >= 0) {
      widget.selectFilter(selected);
    } else {
      widget.addFilterPosition(offset.dx, offset.dy);
    }
  }

  onLongMove(LongPressMoveUpdateDetails details) {
    Offset offset = widget.controller.toScene(
      details.localPosition,
    );
    if (widget.extState.resizeFilterMode) {
      widget.changeTopRightOffset(offset.dx, offset.dy);
      return;
    }
    if (widget.extState.hasSelection) {
      widget.moveFilterPosition(offset.dx, offset.dy);
      return;
    }
  }

  onLongPressStart(LongPressStartDetails details) {
    Offset offset = widget.controller.toScene(
      details.localPosition,
    );
    int curIndex = widget.extState.selectedFilterIndex;
    if (curIndex > -1) {
      var curFilter = widget.extState.getSelectedPosition();
      if ((curFilter != null) &&
          (!curFilter
              .isRounded) && // for resizing circles just remove this condition
          _detectDragAreaClick(offset, curFilter)) {
        widget.changeTopRightOffset(offset.dx, offset.dy);
        return; //if we in resize mode, don't change selected index
      }
    }
    var selected = _detectSelectedFilter(offset);
    widget.selectFilter(selected);
    if (selected >= 0) {
      widget.moveFilterPosition(offset.dx, offset.dy);
    }
  }

  int _detectSelectedFilter(Offset offset) {
    int index = -1;
    double dist = 10000000;
    widget.extState.positions.asMap().forEach((key, value) {
      var tmp =
          sqrt(pow(value.posX - offset.dx, 2) + pow(value.posY - offset.dy, 2));
      if (value.isInnerPoint(offset.dx.toInt(), offset.dy.toInt())) {
        if (tmp < dist) {
          index = key;
          dist = tmp;
        }
      }
    });
    return index;
  }

  bool _detectDragAreaClick(Offset click, FilterPosition? filter) {
    if (filter == null) return false;
    var rect = filter.getResizingAreaRect(imgPixelsInDP);
    var rect2 = Rect.fromCenter(
        center: rect.center,
        width: (rect.width + 2) * 1.15, //let's extend click area +15%
        height: (rect.height + 2) * 1.15);
    return rect2.contains(click);
  }

  void _calculateScaleUpdate() {
    var currentImgDPPX = devicePixelsInDP / widget.controller.value.row0[0];
    if ((currentImgDPPX * 100).round() != (imgPixelsInDP * 100).round()) {
      setState(() {
        imgPixelsInDP = currentImgDPPX;
      });
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(listenerCallback);
    super.dispose();
  }
}
