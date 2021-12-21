import 'package:privacyblur/src/data/services/face_detection.dart';
import 'package:privacyblur/src/screens/image/utils/positions_utils.dart';
import 'package:privacyblur/src/utils/image_filter/helpers/filter_result.dart';
import 'package:privacyblur/src/widgets/message_bar.dart';

import '../utils/filter_position.dart';
import 'constants.dart';

enum EditTool { EditSize, EditShape, EditGranularity, EditType }
enum FeedbackAction { ShowMessage, Navigate }

/// state to show message in UI
class ImageStateFeedback extends ImageStateBase {
  final String messageData;
  final MessageBarType messageType;
  final Set<FeedbackAction> feedback;
  final Map<String, dynamic>? positionalArgs;

  ImageStateFeedback(this.messageData,
      {this.messageType = MessageBarType.information,
      this.feedback = const {FeedbackAction.ShowMessage},
      this.positionalArgs});
}

/// state to generate content on screen
class ImageStateScreen extends ImageStateBase {
  String filename = "";
  late ImageFilterResult image;
  List<FilterPosition> positions = List.empty(growable: true);
  int selectedFilterIndex = -1;
  bool resizeFilterMode = false;
  bool savedOnce = false;

  // maybe remove from bloc in next version. ...Why?
  bool get hasSelection {
    return positions.isNotEmpty;
  }

  bool get isImageSelected => getSelectedPosition() == null;

  bool isImageSaved = false;
  EditTool activeTool = EditTool.EditSize;
  int maxRadius = 300; //will be changed once on image set
  int maxPower = 50; //will be changed once on image set

  void resetSelection() {
    positions.clear();
    selectedFilterIndex = -1;
    resizeFilterMode = false;
  }

  void positionsUpdateOrder() {
    selectedFilterIndex =
        PositionsUtils.changeAreasDrawOrder(positions, selectedFilterIndex);
  }

  void positionsMark2Redraw() {
    PositionsUtils.markCrossedAreas(positions, selectedFilterIndex);
  }

  FilterPosition? getSelectedPosition() {
    var canGetPosition = selectedFilterIndex >= 0 &&
        selectedFilterIndex < positions.length &&
        positions[selectedFilterIndex].posX > ImgConst.undefinedPosValue &&
        positions[selectedFilterIndex].posY > ImgConst.undefinedPosValue;
    if (!canGetPosition) return null;
    return positions[selectedFilterIndex];
  }

  bool _addFace(Face face) {
    if (PositionsUtils.checkNewFace(positions, face)) {
      positions.add(FilterPosition(maxRadius)
        ..posX = face.x.toDouble()
        ..posY = face.y.toDouble()
        ..radiusRatio = face.radius / maxRadius);
      return true;
    } else {
      return false;
    }
  }

  void addPosition(double x, double y) {
    positions.add(FilterPosition(maxRadius)
      ..posX = x
      ..posY = y);
  }

  void removePositionObject(FilterPosition pos) {
    var index = positions.indexWhere((element) => element == pos);
    positions.remove(pos);
    index--;
    if (index < 0) {
      index = positions.length - 1;
    }
    selectedFilterIndex = index;
    resizeFilterMode = false;
  }

  bool addFaces(Faces arr) {
    bool added = false;
    for (var face in arr) {
      if (_addFace(face)) {
        added = true;
      }
    }
    if (added) positionsUpdateOrder();
    return added;
  }

  ImageStateScreen clone() {
    var newImageStateScreen = ImageStateScreen()
      ..image = image
      ..filename = filename
      ..isImageSaved = isImageSaved
      ..activeTool = activeTool
      ..maxPower = maxPower
      ..selectedFilterIndex = selectedFilterIndex
      ..resizeFilterMode = resizeFilterMode
      ..positions = [...positions]
      ..savedOnce = savedOnce
      ..maxRadius = maxRadius;
    return newImageStateScreen;
  }
}

class ImageStateBase {}
