import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:ui' as img_tools;

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:privacyblur/resources/localization/keys.dart';
import 'package:privacyblur/src/data/services/face_detection.dart'
    if (BuildFlavor.isFoss) 'package:privacyblur/src/data/services/face_detection_foss.dart';
import 'package:privacyblur/src/screens/image/helpers/constants.dart';
import 'package:privacyblur/src/utils/image_filter/helpers/matrix_blur.dart';
import 'package:privacyblur/src/utils/image_filter/helpers/matrix_pixelate.dart';
import 'package:privacyblur/src/utils/image_filter/image_filters.dart';
import 'package:privacyblur/src/widgets/message_bar.dart';

import 'helpers/image_classes_helper.dart';
import 'helpers/image_events.dart';
import 'helpers/image_states.dart';
import 'image_repo.dart';
import 'utils/image_tools.dart';

// may be move to image_events, but it became visible in project, not only inside BLoC
class _yieldStateInternally extends ImageEventBase {}

class ImageBloc extends Bloc<ImageEventBase, ImageStateBase?> {
  final ImageStateScreen _blocState = ImageStateScreen();
  final ImageRepository _repo;
  final ImgTools imgTools; //for mocking saving operations in future tests
  final FaceDetection faceDetection;

  Timer? _deferredFuture;
  final Duration _deferred =
      const Duration(milliseconds: ImgConst.applyDelayDuration);

  ImageBloc(this._repo, this.imgTools, this.faceDetection) : super(null) {
    on<ImageEventSelected>(imageSelected);
    on<ImageEventEditToolSelected>(imageToolSelected);
    on<ImageEventFilterGranularity>(powerFilterChanged);
    on<ImageEventShapeSize>(radiusFilterChanged);
    on<ImageEventPositionChanged>(positionFilterChanged);
    on<ImageEventNewFilter>(addFilter);
    on<ImageEventExistingFilterSelected>(selectFilterIndex);
    on<ImageEventCurrentFilterDelete>(deleteFilterIndex);
    on<ImageEventSave2Disk>(saveImage);
    on<ImageEventFilterPixelate>(filterTypeChanged);
    on<ImageEventShapeRounded>(filterShapeChanged);
    on<ImageEventDetectFaces>(detectFaces);
    on<_yieldStateInternally>((state, emit) => emit(_blocState.clone()));
  }

  var imageFilter = ImageAppFilter();

  void _filterInArea() {
    for (var position in _blocState.positions) {
      if (position.canceled || position.forceRedraw) {
        if (position.isPixelate) {
          imageFilter.setFilter(MatrixAppPixelate(
              (_blocState.maxPower * position.granularityRatio).toInt()));
        } else {
          imageFilter.setFilter(MatrixAppBlur(
              (_blocState.maxPower * position.granularityRatio).toInt()));
        }
        imageFilter.apply2Area(position.posX, position.posY,
            position.getVisibleRadius(), position.isRounded);
        position.canceled = false;
        position.forceRedraw = false;
      }
    }
  }

  void _applyCurrentFilter() {
    _deferredFuture?.cancel();
    _deferredFuture = Timer(_deferred, () async {
      _filterInArea();
      _blocState.image = await imageFilter.getImage();
      add(_yieldStateInternally());
    });
  }

  void _cancelPosition(FilterPosition position) {
    if (position.canceled) return;
    position.canceled = true;
    imageFilter.cancelArea(position.posX, position.posY,
        position.getVisibleRadius(), position.isRounded);
  }

  void _cancelCurrentFilters(FilterPosition position) {
    if (position.canceled) return;
    _cancelPosition(position);
    _blocState.positionsMark2Redraw();
    for (var pos in _blocState.positions) {
      if (pos.forceRedraw) {
        _cancelPosition(pos);
      }
    }
  }

  ImageStateFeedback _showFilterState() {
    String message = editToolMessage[_blocState.activeTool]!;
    return ImageStateFeedback(message, messageType: MessageBarType.information);
  }

  void filterShapeChanged(
      ImageEventShapeRounded event, Emitter<ImageStateBase?> emit) {
    var position = _blocState.getSelectedPosition();
    if (position != null) {
      if (event.isRounded == position.isRounded) return;
      _cancelCurrentFilters(position);
      position.isRounded = event.isRounded;
      _applyCurrentFilter();
      emit(_blocState.clone()); //needed
    }
  }

  void filterTypeChanged(
      ImageEventFilterPixelate event, Emitter<ImageStateBase?> emit) {
    var position = _blocState.getSelectedPosition();
    if (position != null) {
      if (event.isPixelate == position.isPixelate) return;
      _cancelCurrentFilters(position);
      position.isPixelate = event.isPixelate;
      _blocState.positionsUpdateOrder();
      _applyCurrentFilter(); //yield _blocState.clone(); not needed here
    }
  }

  FutureOr<void> saveImage(
      ImageEventSave2Disk event, Emitter<ImageStateBase?> emit) async {
    imageFilter.transactionCommit();
    _blocState.resetSelection();
    _blocState.image = await imageFilter.getImage();
    _blocState.isImageSaved = await imgTools.save2Gallery(
        imageFilter.imageWidth(),
        imageFilter.imageHeight(),
        imageFilter.getImageARGB32(),
        event.needOverride);
    if (_blocState.isImageSaved) {
      _blocState.savedOnce = true;
      emit(ImageStateFeedback(Keys.Messages_Infos_Success_Saved,
          messageType: MessageBarType.information));
    } else {
      emit(ImageStateFeedback(Keys.Messages_Errors_File_System,
          messageType: MessageBarType.failure));
    }
    emit(_blocState.clone());
  }

  void selectFilterIndex(ImageEventExistingFilterSelected event,
      Emitter<ImageStateBase?> emit) {
    _blocState.selectedFilterIndex = event.index;
    emit(_blocState.clone()); //needed
  }

  FutureOr<void> deleteFilterIndex(ImageEventCurrentFilterDelete event,
      Emitter<ImageStateBase?> emit) async {
    if (_blocState.positions.length <= 1) {
      imageFilter.transactionCancel();
      _blocState.resetSelection();
      _blocState.image = await imageFilter.getImage();
      if (_blocState.positions.isEmpty) _blocState.isImageSaved = true;
      emit(_blocState.clone()); //needed
      return;
    }
    var position = _blocState.getSelectedPosition();
    if (position != null) {
      _cancelCurrentFilters(position);
      _blocState.removePositionObject(position);
      _applyCurrentFilter(); //yield _blocState.clone(); - not needed here
    }
  }

  void addFilter(
      ImageEventNewFilter event, Emitter<ImageStateBase?> emit) {
    imageFilter.transactionStart();
    _blocState.addPosition(event.x, event.y);
    _blocState.selectedFilterIndex = _blocState.positions.length - 1;
    _blocState.isImageSaved = false;
    _applyCurrentFilter();
    emit(_blocState.clone()); //needed
  }

  void positionFilterChanged(
      ImageEventPositionChanged event, Emitter<ImageStateBase?> emit) {
    var position = _blocState.getSelectedPosition();
    if (position != null) {
      _cancelCurrentFilters(position);
      position.posX = event.x.toInt();
      position.posY = event.y.toInt();
      _applyCurrentFilter();
      emit(_blocState.clone()); //needed
    }
  }

  void radiusFilterChanged(
      ImageEventShapeSize event, Emitter<ImageStateBase?> emit) {
    var position = _blocState.getSelectedPosition();
    if (position != null) {
      _cancelCurrentFilters(position);
      position.radiusRatio = event.radius;
      _applyCurrentFilter();
      emit(_blocState.clone()); //needed
    }
  }

  void powerFilterChanged(
      ImageEventFilterGranularity event, Emitter<ImageStateBase?> emit) {
    var position = _blocState.getSelectedPosition();
    if (position != null) {
      _cancelCurrentFilters(position);
      position.granularityRatio = event.power;
      _blocState.positionsUpdateOrder();
      _applyCurrentFilter();
      emit(_blocState.clone()); //not really needed here, but now its necessary
    }
  }

  void imageToolSelected(
      ImageEventEditToolSelected event, Emitter<ImageStateBase?> emit) {
    _blocState.activeTool = event.activeTool;
    emit(_showFilterState());
    emit(_blocState.clone());
  }

  FutureOr<void> imageSelected(
      ImageEventSelected event, Emitter<ImageStateBase?> emit) async {
    var lastPath = await _repo.getLastPath();
    var maxImageSize = ImgConst.defaultImageSize;
    if ((lastPath) == event.filename) {
      var heapMemory = await _repo.getHeapSize();
      if (heapMemory > 0) {
        maxImageSize =
            sqrt((heapMemory * ImgConst.partFreeMemory) / 4.0).toInt();
      }
    } else {
      maxImageSize = -1;
      await _repo.setLastPath(event.filename);
    }
    _blocState.filename = event.filename;
    _blocState.isImageSaved = true;
    img_tools.Image? tmpImage;
    try {
      tmpImage = await imgTools.scaleFile(_blocState.filename, maxImageSize);
      if (imgTools.scaled) {
        String origRes = '${imgTools.srcWidth} x ${imgTools.srcHeight}';
        String newRes = '${tmpImage.width} x ${tmpImage.height}';
        emit(ImageStateFeedback(Keys.Messages_Errors_Image_Scale_Down,
            positionalArgs: {"origRes": origRes, "newRes": newRes}));
      }
    } catch (e) {
      emit(
          await _yieldCriticalException(Keys.Messages_Errors_Img_Not_Readable));
      return;
    }
    _blocState.maxRadius = (max(tmpImage.width, tmpImage.height) ~/ 2);
    _blocState.maxPower = (max(tmpImage.width, tmpImage.height) ~/ 35);
    _blocState.resetSelection();
    ImageAppFilter.setMaxProcessedWidth(_blocState.maxRadius * 3);

    /// VERY IMPORTANT TO USE AWAIT HERE!!!
    _blocState.image = await imageFilter.setImage(tmpImage);
    emit(_blocState.clone());
    await _repo.removeLastPath();
  }

  FutureOr<void> detectFaces(
      ImageEventDetectFaces event, Emitter<ImageStateBase?> emit) async {
    imageFilter.transactionStart();
    var detectionResult = await faceDetection.detectFaces(
        Platform.isIOS
            ? imageFilter.getImageARGB8()
            : imageFilter.getImageNV21(),
        imageFilter.imageWidth(),
        imageFilter.imageHeight());
    if (_blocState.addFaces(detectionResult)) _blocState.isImageSaved = false;
    _blocState.selectedFilterIndex = _blocState.positions.length - 1;
    _applyCurrentFilter();
    emit(_blocState.clone());
  }

  Future<ImageStateFeedback> _yieldCriticalException(String title) async {
    await _repo.removeLastPath();
    return ImageStateFeedback(
      title,
      messageType: MessageBarType.failure,
      feedback: {FeedbackAction.Navigate, FeedbackAction.ShowMessage},
    );
  }
}
