import 'package:flutter/Material.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:privacyblur/resources/localization/keys.dart';
import 'package:privacyblur/src/di.dart';
import 'package:privacyblur/src/router.dart';
import 'package:privacyblur/src/screens/image/utils/internal_layout.dart';
import 'package:privacyblur/src/widgets/adaptive_widgets_builder.dart';

class ImagePreviewScreen extends StatelessWidget {
  final DependencyInjection di;
  final AppRouter router;
  late InternalLayout internalLayout;

  ImagePreviewScreen(this.di, this.router);

  @override
  Widget build(BuildContext context) {
    internalLayout = InternalLayout(context);
    return ScaffoldWithAppBar.build(
      context: context,
      title: translate(Keys.App_Name),
      body: SafeArea(
        child: _buildPreview(context),
        top: internalLayout.landscapeMode,
        bottom: internalLayout.landscapeMode,
        left: !internalLayout.landscapeMode,
        right: !internalLayout.landscapeMode,
      ),
    );
  }

  Widget _buildPreview(BuildContext context) {
    return Container(

    );
  }
}
