import 'dart:math';

import 'package:flutter/Material.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:privacyblur/resources/localization/keys.dart';
import 'package:privacyblur/src/di.dart';
import 'package:privacyblur/src/router.dart';
import 'package:privacyblur/src/screens/image/utils/internal_layout.dart';
import 'package:privacyblur/src/screens/image/widgets/custom_painter.dart';
import 'package:privacyblur/src/utils/image_filter/helpers/filter_result.dart';
import 'package:privacyblur/src/widgets/adaptive_widgets_builder.dart';

// ignore: must_be_immutable
class ImagePreviewScreen extends StatefulWidget {
  final DependencyInjection di;
  final AppRouter router;
  final ImageFilterResult image;
  final TransformationController transformationController;

  ImagePreviewScreen(this.di, this.router, this.transformationController, this.image);

  @override
  _ImagePreviewScreenState createState() => _ImagePreviewScreenState();
}

class _ImagePreviewScreenState extends State<ImagePreviewScreen> {
  late InternalLayout internalLayout;

  @override
  void initState() {
    
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    internalLayout = InternalLayout(context);
    return ScaffoldWithAppBar.build(
      context: context,
      actions: [],
      title: translate(Keys.App_Name),
      body: SafeArea(
        child: _buildPreview(context),
      ),
    );
  }

  Widget _buildPreview(BuildContext context) {
    return LayoutBuilder(builder: (_, constraints) {
      var wScale = constraints.maxWidth / widget.image.mainImage.width;
      var hScale = constraints.maxHeight / widget.image.mainImage.height;
      var minScale = min(wScale, hScale); //to fit image
      var initialScale = max(wScale, hScale);
      var imageMinWidth = widget.image.mainImage.width * minScale;
      var imageMinHeight = widget.image.mainImage.height * minScale;
      var horizontalBorder =
          ((constraints.maxWidth - imageMinWidth).abs() / (minScale));
      var verticalBorder =
          ((constraints.maxHeight - imageMinHeight).abs() / (minScale));
      EdgeInsets boundaryMargin =
          EdgeInsets.fromLTRB(0, 0, horizontalBorder, verticalBorder);

      return InteractiveViewer(
          maxScale: 10,
          scaleEnabled: true,
          panEnabled: true,
          constrained: false,
          boundaryMargin: boundaryMargin,
          minScale: minScale / initialScale,
          transformationController: widget.transformationController,
          child: SizedBox(
              width: widget.image.mainImage.width.toDouble(),
              height: widget.image.mainImage.height.toDouble(),
              child: CustomPaint(
                size: Size(widget.image.mainImage.height.toDouble(),
                    widget.image.mainImage.width.toDouble()),
                isComplex: true,
                willChange: true,
                painter: ImgPainter(widget.image),
              )));
    });
  }
}
