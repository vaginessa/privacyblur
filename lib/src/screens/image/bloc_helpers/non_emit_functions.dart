import 'dart:typed_data';
import 'dart:ui' as img_tools;

import 'package:privacyblur/src/screens/image/utils/filter_position.dart';
import 'package:privacyblur/src/screens/image/helpers/image_states.dart';
import 'package:privacyblur/src/screens/image/utils/image_tools.dart';
import 'package:privacyblur/src/utils/image_filter/helpers/filter_result.dart';
import 'package:privacyblur/src/utils/image_filter/helpers/matrix_blur.dart';
import 'package:privacyblur/src/utils/image_filter/helpers/matrix_pixelate.dart';
import 'package:privacyblur/src/utils/image_filter/image_filters.dart';

class ImageOperationsHelper {
  var imageFilter = ImageAppFilter();

  void cancelPosition(FilterPosition position) {
    if (position.canceled) return;
    position.canceled = true;
    if (position.isRounded) {
      imageFilter.cancelCircle(
          position.posX.toInt(), position.posY.toInt(), position.getVisibleRadius());
    } else {
      imageFilter.cancelSquare(position.posX.toInt(), position.posY.toInt(),
          position.getVisibleWidth(), position.getVisibleHeight());
    }
  }

  void cancelCurrentFilters(
      FilterPosition position, ImageStateScreen blocState) {
    if (position.canceled) return;
    cancelPosition(position);
    blocState.positionsMark2Redraw();
    for (var pos in blocState.positions) {
      if (pos.forceRedraw) {
        cancelPosition(pos);
      }
    }
  }

  void filterInArea(List<FilterPosition> positions, int maxPower) {
    for (var position in positions) {
      if (position.canceled || position.forceRedraw) {
        if (position.isPixelate) {
          imageFilter.setFilter(MatrixAppPixelate(
              (maxPower * position.granularityRatio).toInt()));
        } else {
          imageFilter.setFilter(
              MatrixAppBlur((maxPower * position.granularityRatio).toInt()));
        }
        if (position.isRounded) {
          imageFilter.apply2Circle(
              position.posX.toInt(), position.posY.toInt(), position.getVisibleRadius());
        } else {
          imageFilter.apply2Square(position.posX.toInt(), position.posY.toInt(),
              position.getVisibleWidth(), position.getVisibleHeight());
        }
        position.canceled = false;
        position.forceRedraw = false;
      }
    }
  }

  Future<ImageFilterResult> getImage() {
    return imageFilter.getImage();
  }

  Future<void> saveImage(
      ImageStateScreen blocState, ImgTools imgTools, bool needOverride) async {
    imageFilter.transactionCommit();
    blocState.resetSelection();
    blocState.image = await imageFilter.getImage();
    blocState.isImageSaved = await imgTools.save2Gallery(
        imageFilter.imageWidth(),
        imageFilter.imageHeight(),
        imageFilter.getImageARGB32(),
        needOverride);
    imageFilter.transactionCancel();
  }

  void transactionCancel() => imageFilter.transactionCancel();

  void transactionCommit() => imageFilter.transactionCommit();

  void transactionStart() => imageFilter.transactionStart();

  Future<ImageFilterResult> setImage(img_tools.Image image) async =>
      imageFilter.setImage(image);

  Uint8List getImageARGB8() => imageFilter.getImageARGB8();

  Uint8List getImageNV21() => imageFilter.getImageNV21();

  int imageWidth() => imageFilter.imageWidth();

  int imageHeight() => imageFilter.imageHeight();
}
