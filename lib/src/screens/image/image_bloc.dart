import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:ui' as img_tools;

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:privacyblur/resources/localization/keys.dart';
import 'package:privacyblur/src/data/services/face_detection.dart'
    if (BuildFlavor.isFoss) 'package:privacyblur/src/data/services/face_detection_foss.dart';
import 'package:privacyblur/src/screens/image/bloc_helpers/non_emit_functions.dart';
import 'package:privacyblur/src/screens/image/helpers/constants.dart';
import 'package:privacyblur/src/utils/image_filter/image_filters.dart';
import 'package:privacyblur/src/widgets/message_bar.dart';

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
  final ImageOperationsHelper imageOperationsHelper =
      ImageOperationsHelper(); // move to DI ?

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
    on<ImageEventTopRight>(resizeCurrentFilter);
    on<_yieldStateInternally>((state, emit) => emit(_blocState.clone()));
  }

  void _delayedApplyFilter() {
    _deferredFuture?.cancel();
    _deferredFuture = Timer(_deferred, () async {
      imageOperationsHelper.filterInArea(
          _blocState.positions, _blocState.maxPower);
      _blocState.image = await imageOperationsHelper.getImage();
      add(_yieldStateInternally());
    });
  }

  void filterShapeChanged(
      ImageEventShapeRounded event, Emitter<ImageStateBase?> emit) {
    var position = _blocState.getSelectedPosition();
    if (position != null) {
      if (event.isRounded == position.isRounded) return;
      imageOperationsHelper.cancelCurrentFilters(position, _blocState);
      position.isRounded = event.isRounded;
      _delayedApplyFilter();
      emit(_blocState.clone()); //needed
    }
  }

  void filterTypeChanged(
      ImageEventFilterPixelate event, Emitter<ImageStateBase?> emit) {
    var position = _blocState.getSelectedPosition();
    if (position != null) {
      if (event.isPixelate == position.isPixelate) return;
      imageOperationsHelper.cancelCurrentFilters(position, _blocState);
      position.isPixelate = event.isPixelate;
      _blocState.positionsUpdateOrder();
      _delayedApplyFilter(); //yield _blocState.clone(); not needed here
    }
  }

  FutureOr<void> saveImage(
      ImageEventSave2Disk event, Emitter<ImageStateBase?> emit) async {
    _blocState.resizeFilterMode = false;
    await imageOperationsHelper.saveImage(
        _blocState, imgTools, event.needOverride);
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

  void selectFilterIndex(
      ImageEventExistingFilterSelected event, Emitter<ImageStateBase?> emit) {
    _blocState.selectedFilterIndex = event.index;
    _blocState.resizeFilterMode = false;
    emit(_blocState.clone()); //needed
  }

  FutureOr<void> deleteFilterIndex(ImageEventCurrentFilterDelete event,
      Emitter<ImageStateBase?> emit) async {
    _blocState.resizeFilterMode = false;
    if (_blocState.positions.length <= 1) {
      imageOperationsHelper.transactionCancel();
      _blocState.resetSelection();
      _blocState.image = await imageOperationsHelper.getImage();
      if (_blocState.positions.isEmpty) _blocState.isImageSaved = true;
      _delayedApplyFilter();
      emit(_blocState.clone()); //needed
      return;
    }
    var position = _blocState.getSelectedPosition();
    if (position != null) {
      imageOperationsHelper.cancelCurrentFilters(position, _blocState);
      _blocState.removePositionObject(position);
      _delayedApplyFilter(); //yield _blocState.clone(); - not needed here
    }
  }

  void addFilter(ImageEventNewFilter event, Emitter<ImageStateBase?> emit) {
    imageOperationsHelper.transactionStart();
    _blocState.resizeFilterMode = false;
    _blocState.addPosition(event.x, event.y);
    _blocState.selectedFilterIndex = _blocState.positions.length - 1;
    _blocState.isImageSaved = false;
    _blocState.positionsUpdateOrder();
    _delayedApplyFilter();
    emit(_blocState.clone()); //needed
  }

  void positionFilterChanged(
      ImageEventPositionChanged event, Emitter<ImageStateBase?> emit) {
    _blocState.resizeFilterMode = false;
    var position = _blocState.getSelectedPosition();
    if (position != null) {
      imageOperationsHelper.cancelCurrentFilters(position, _blocState);
      position.posX = event.x;
      position.posY = event.y;
      _delayedApplyFilter();
      emit(_blocState.clone()); //needed
    }
  }

  void radiusFilterChanged(
      ImageEventShapeSize event, Emitter<ImageStateBase?> emit) {
    var position = _blocState.getSelectedPosition();
    if (position != null) {
      imageOperationsHelper.cancelCurrentFilters(position, _blocState);
      position.radiusRatio = event.radius;
      _delayedApplyFilter();
      emit(_blocState.clone()); //needed
    }
  }

  void powerFilterChanged(
      ImageEventFilterGranularity event, Emitter<ImageStateBase?> emit) {
    var position = _blocState.getSelectedPosition();
    if (position != null) {
      imageOperationsHelper.cancelCurrentFilters(position, _blocState);
      position.granularityRatio = event.power;
      _blocState.positionsUpdateOrder();
      _delayedApplyFilter();
      emit(_blocState.clone()); //not really needed here, but now its necessary
    }
  }

  void imageToolSelected(
      ImageEventEditToolSelected event, Emitter<ImageStateBase?> emit) {
    _blocState.activeTool = event.activeTool;
    emit(ImageStateFeedback(editToolMessage[_blocState.activeTool]!,
        messageType: MessageBarType.information));
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
    _blocState.resizeFilterMode = false;
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
    _blocState.maxRadius = max(tmpImage.width, tmpImage.height) ~/ 1.8;
    _blocState.maxPower = max(tmpImage.width, tmpImage.height) ~/ 35;
    _blocState.resetSelection();
    ImageAppFilter.setMaxProcessedWidth(_blocState.maxRadius * 3);

    /// VERY IMPORTANT TO USE AWAIT HERE!!!
    _blocState.image = await imageOperationsHelper.setImage(tmpImage);
    emit(_blocState.clone());
    await _repo.removeLastPath();
  }

  FutureOr<void> detectFaces(
      ImageEventDetectFaces event, Emitter<ImageStateBase?> emit) async {
    imageOperationsHelper.transactionStart();
    var detectionResult = await faceDetection.detectFaces(
        Platform.isIOS
            ? imageOperationsHelper.getImageARGB8()
            : imageOperationsHelper.getImageNV21(),
        imageOperationsHelper.imageWidth(),
        imageOperationsHelper.imageHeight());
    if (_blocState.addFaces(detectionResult)) _blocState.isImageSaved = false;
    _blocState.selectedFilterIndex = _blocState.positions.length - 1;
    _blocState.resizeFilterMode = false;
    _delayedApplyFilter();
    emit(_blocState.clone());
  }

  void resizeCurrentFilter(
      ImageEventTopRight event, Emitter<ImageStateBase?> emit) {
    _blocState.resizeFilterMode = true;
    var position = _blocState.getSelectedPosition();
    if (position != null) {
      imageOperationsHelper.cancelCurrentFilters(position, _blocState);
      position.rebuildRadiusFromClick(event.x, event.y);
      _delayedApplyFilter();
      emit(_blocState.clone());
    }
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
