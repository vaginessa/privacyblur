import 'package:flutter/material.dart';

class Section extends StatelessWidget {
  final Widget child;
  final double? sectionHeight;
  final double? aspectRatio;

  Section({required this.child, required this.sectionHeight})
      : this.aspectRatio = null;
  Section.withAspectRatio({required this.child, this.aspectRatio = 1})
      : this.sectionHeight = null;

  @override
  Widget build(BuildContext context) {
    if (aspectRatio != null) {
      return AspectRatio(child: this.child, aspectRatio: this.aspectRatio!);
    } else {
      return SizedBox(
          height: this.sectionHeight!,
          child: Center(
            child: this.child,
          ));
    }
  }
}
