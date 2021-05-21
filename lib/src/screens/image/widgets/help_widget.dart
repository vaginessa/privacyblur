import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:privacyblur/resources/localization/keys.dart';
import 'package:privacyblur/src/screens/image/utils/internal_layout.dart';
import 'package:privacyblur/src/widgets/theme/icons_provider.dart';
import 'package:privacyblur/src/widgets/theme/theme_provider.dart';

class HelpWidget extends StatelessWidget {
  static late InternalLayout _internalLayout;
  final double height;

  HelpWidget(this.height);

  @override
  Widget build(BuildContext context) {
    _internalLayout = InternalLayout(context);
    return Scrollbar(
      isAlwaysShown: true,
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(_internalLayout.spacer),
          child: Column(
            children: generateHelpStrings(context),
          ),
        ),
      ),
    );
  }

  List<Widget> generateHelpStrings(BuildContext context) {
    List<Widget> list = List.empty(growable: true);
    list.add(_helpTemplate(context, AppIcons.click, Keys.Help_Lines_Help0));
    list.add(_helpTemplate(context, AppIcons.drag, Keys.Help_Lines_Help1));
    list.add(
        _helpTemplate(context, AppIcons.granularity, Keys.Help_Lines_Help2));
    list.add(_helpTemplate(context, AppIcons.done, Keys.Help_Lines_Help3));
    list.add(_helpTemplate(context, AppIcons.save, Keys.Help_Lines_Help4));
    return list;
  }

  Widget _helpTemplate(BuildContext context, IconData icon, String text) {
    return Padding(
      padding: EdgeInsets.all(_internalLayout.spacer * 0.6),
      child: Row(
        children: [
          Padding(
            padding:
                EdgeInsets.fromLTRB(0.0, 0, _internalLayout.spacer * 1.5, 0),
            child: Icon(icon,
                color: AppTheme.fontColor(context),
                size: _internalLayout.spacer * 1.6),
          ),
          Flexible(
              child: Text(
            translate(text),
            style: TextStyle(
                color: AppTheme.fontColor(context),
                fontSize: _internalLayout.spacer * 1.4),
          ))
        ],
      ),
    );
  }
}
