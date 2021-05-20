import 'package:privacyblur/src/utils/image_filter/helpers/filter_result.dart';
import 'package:privacyblur/src/widgets/message_bar.dart';

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
      {this.messageType = MessageBarType.Information,
      this.feedback = const {FeedbackAction.ShowMessage},
      this.positionalArgs});
}

/// state to generate content on screen
class ImageStateScreen extends ImageStateBase {
  String filename = "";
  late ImageFilterResult image;
  double granularityRatio = ImgConst.startGranularityRatio;
  double radiusRatio = ImgConst.startRadiusRatio;
  int posX = ImgConst.undefinedPosValue;
  int posY = ImgConst.undefinedPosValue;

  // maybe remove from bloc in next version. ...Why?
  bool get hasSelection {
    return (posX > ImgConst.undefinedPosValue &&
        posY > ImgConst.undefinedPosValue);
  }

  bool isImageSaved = false;
  bool isRounded = true;
  bool isPixelate = true;
  EditTool activeTool = EditTool.EditSize;
  int maxRadius = 300; //will be changed once on image set
  int maxPower = 50; //will be changed once on image set

  void resetSelection() {
    posX = ImgConst.undefinedPosValue;
    posY = ImgConst.undefinedPosValue;
  }

  ImageStateScreen clone() {
    var newImageStateScreen = ImageStateScreen()
      ..image = this.image
      ..filename = this.filename
      ..granularityRatio = this.granularityRatio
      ..radiusRatio = this.radiusRatio
      ..posX = this.posX
      ..posY = this.posY
      ..isImageSaved = this.isImageSaved
      ..isRounded = this.isRounded
      ..isPixelate = this.isPixelate
      ..activeTool = this.activeTool
      ..maxPower = this.maxPower
      ..maxRadius = this.maxRadius;
    return newImageStateScreen;
  }
}

/// base state class with override for == operator
class ImageStateBase {
  static int _globalSerial = 1;
  int _blocSerial = 0;

  ImageStateBase() {
    _globalSerial++;
    _blocSerial = _globalSerial;
  }

  @override
  bool operator ==(other) {
    if (other is ImageStateBase) {
      return this._blocSerial == other._blocSerial;
    }
    return false;
  }

  @override
  int get hashCode => super.hashCode;
}
