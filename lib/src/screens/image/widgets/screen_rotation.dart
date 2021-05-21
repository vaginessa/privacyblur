import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:privacyblur/src/utils/layout_config.dart';
import 'package:privacyblur/src/widgets/theme/theme_provider.dart';

class ScreenRotation extends StatelessWidget {
  final Widget Function(
      BuildContext context, double width, double height, bool landscape) view1;
  final Widget Function(
      BuildContext context, double width, double height, bool landscape) view2;
  final double view2Portrait;
  final double view2Landscape;
  final double baseHeight;

  ScreenRotation(
      {required this.view1,
      required this.view2,
      required this.view2Portrait,
      required this.view2Landscape,
      required this.baseHeight
      });

  @override
  Widget build(BuildContext context) {
    var config = LayoutConfig(context);
    var baseWidth = MediaQuery.of(context).size.width;

    if (config.landscapeMode) {
      double view2Width = view2Landscape;
      double view1Width = baseWidth - view2Landscape;

      return Row(
        children: [
          SizedBox(
              width: view1Width.toDouble(),
              child: view1(context, view1Width, baseHeight, true)),
          SizedBox(
              width: view2Width.toDouble(),
              child: view2(context, view2Width, baseHeight, true))
        ],
      );
    } else {
      double view2Height = view2Portrait;
      double view1Height = (baseHeight - view2Height);
      return Column(
        children: [
          SizedBox(
              height: view1Height.toDouble(),
              child: view1(context, baseWidth, view1Height, false)),
          SizedBox(
              height: view2Height.toDouble(),
              child: view2(context, baseWidth, view2Height, false))
        ],
      );
    }
  }
}
