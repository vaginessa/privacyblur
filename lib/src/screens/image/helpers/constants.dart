import 'package:privacyblur/resources/localization/keys.dart';

import 'image_states.dart';

class ImgConst {
  static const undefinedPosValue = -999999;
  static const startGranularityRatio = 0.35;
  static const startRadiusRatio = 0.35;
  static const defaultImageSize = 2400;
  static const imgQuality = 80; //[0..100]
  static const partFreeMemory = 0.7; //[0..1]
  static const applyDelayDuration = 150;
}

const Map<EditTool, String> editToolMessage = {
  EditTool.EditSize: Keys.Buttons_Tool_Size,
  EditTool.EditGranularity: Keys.Buttons_Tool_Grain,
  EditTool.EditShape: Keys.Buttons_Tool_Shape,
  EditTool.EditType: Keys.Buttons_Tool_Type,
};
